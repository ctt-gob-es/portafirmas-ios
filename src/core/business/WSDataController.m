//
//  WSDataController.m
//  PortaFirmasUniv
//
//  Created by Antonio Fiñana on 07/11/12.
//  Copyright (c) 2012 Atos. All rights reserved.
//

#import "WSDataController.h"
#import "NSData+Base64.h"
#import "NSString+XMLSafe.h"
#import "CookieTools.h"
#import "LoginService.h"
#import "Parser.h"

#define SERVER_URL ((NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:kPFUserDefaultsKeyCurrentServer])[kPFUserDefaultsKeyURL]

@implementation WSDataController
@synthesize delegate = _delegate;

struct {
    unsigned int didDoParse : 1;
    unsigned int didReceiveParserWithError : 2;

} delegateRespondsTo;

- (void)setDelegate:(id <WSDelegate>)aDelegate
{
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
        delegateRespondsTo.didDoParse = [_delegate respondsToSelector:@selector(doParse:)];
        delegateRespondsTo.didReceiveParserWithError = [_delegate respondsToSelector:@selector(didReceiveParserWithError:)];
    }
}

- (id)init
{
    self = [super init];
    REQUEST_POST = YES;
    return self;
}

- (id)init:(BOOL)isPOSTRequest
{
    self = [super init];
    REQUEST_POST = isPOSTRequest;
    return self;
}

- (void)loadPostRequestWithData:(NSString *)data code:(NSInteger)code
{
    [self loadPostRequestWithURL: SERVER_URL code: code data: data];
}

- (void)loadPostRequestWithURL:(NSString *)wsURLString code:(NSInteger)code data:(NSString *)data
{
	NSData *msgData = [data dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableURLRequest *request;
	NSString *operationAndData = [NSString stringWithFormat: @"op=%lu&dat=%@",(unsigned long)code, [msgData base64EncodedString]];
	if (!REQUEST_POST) {
		NSString *params = [NSString stringWithFormat:@"?%@", operationAndData];
		params = [self includeSsidIfExists:params];
		NSString *newURL = [wsURLString stringByAppendingString:params];
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:newURL]
										  cachePolicy:NSURLRequestReloadIgnoringCacheData
									  timeoutInterval:TIMEOUT_FOR_SERVER];
	} else {
		NSString *post = operationAndData;
		post = [self includeSsidIfExists:post];
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:wsURLString]
										  cachePolicy:NSURLRequestReloadIgnoringCacheData
									  timeoutInterval:TIMEOUT_FOR_SERVER];
		[request setHTTPMethod:@"POST"];
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setHTTPBody:postData];
		if ([[LoginService instance] serverSupportLogin]) {
			NSDictionary *cookieDict = [CookieTools JSessionID];
			if (cookieDict != nil) {
				[request setAllHTTPHeaderFields:cookieDict];
				[request setHTTPShouldHandleCookies:YES];
			}
		}
	}
	if (dataTask.state == NSURLSessionTaskStateRunning) {
		[dataTask cancel];
		connectionInProgress = nil;
	}
	NSURLSessionConfiguration * defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
	defaultConfigObject.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	connectionInProgress = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
	self->dataTask = [connectionInProgress dataTaskWithRequest:request
											 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
					  {
		self->xmlData = [NSMutableData dataWithData:data];
		[self doParse: self->xmlData];
	}];
}

-(void) postSignRequestWithFIRe:(NSData *)data code: (NSInteger) code success:(void(^)(NSDictionary *content))success failure:(void(^)(NSError *error))failure {
		NSString *opParameter = @"op";
		NSString *datParameter = @"dat";
		NSString *baseURL = SERVER_URL;
		NSString *params = [NSString stringWithFormat: @"%@=%lu&%@=%@", opParameter,
							(unsigned long)code, datParameter, [data base64EncodedString]];
		NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setURL:[NSURL URLWithString:baseURL]];
		[request setHTTPMethod:@"POST"];
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[request setHTTPBody:postData];
		[request setHTTPShouldHandleCookies:YES];
		[request setTimeoutInterval:kPFRequestTimeoutInterval];
		NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
		[[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			if (error) {
				failure(error);
			} else  {
				Parser *parser = [Parser new];
				[parser parseFIRMeResponse:data success:^(NSDictionary *content) {
					success(content);
				} failure:^(NSError *error) {
					failure(error);
				}];
			}
		}] resume];
}

- (void)loadRequestsWithURL:( NSString *)wsURLString
{
    NSURL *url = [NSURL URLWithString:wsURLString];
    // Create a request object with that URL
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:TIMEOUT_FOR_SERVER];
    if (dataTask.state == NSURLSessionTaskStateRunning) {
        [dataTask cancel];
        connectionInProgress = nil;
    }
	NSURLSessionConfiguration * defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
	defaultConfigObject.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	connectionInProgress = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
	self->dataTask = [connectionInProgress dataTaskWithRequest:request
												completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
									  {
		self->xmlData = [NSMutableData dataWithData:data];
		[self doParse: self->xmlData];
	}];

}

-(void) URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
	[xmlData appendData:data];
}

-(void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
	dispatch_async(dispatch_get_main_queue(), ^{
		[SVProgressHUD dismiss];
	});
	connectionInProgress = nil;
	xmlData = nil;
	NSString *errorString = [NSString stringWithFormat:@"Load failed: %@",
							 [error localizedDescription]];

	if ([_delegate respondsToSelector:@selector(didReceiveParserWithError:)]) {
		[_delegate didReceiveParserWithError:errorString];
	}
}

- (void)doParse:(NSData *)data
{
    if(data.length != 0) {
        [_delegate doParse: data];
    }
}

- (void)cancelConnection
{
    if (dataTask.state == NSURLSessionTaskStateRunning) {
        [dataTask cancel];
        connectionInProgress = nil;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void)startConnection
{
    if (dataTask.state != NSURLSessionTaskStateRunning) {
        [dataTask resume];
    }
}

- (NSString *) includeSsidIfExists: (NSString *)currentParams {
	NSString *paramsWithSsid = currentParams;
	if ([[LoginService instance] sessionId]){
		paramsWithSsid = [NSString stringWithFormat:@"%@%@", currentParams , [NSString stringWithFormat:@"&ssid=%@", [[LoginService instance] sessionId]]];
	}
	return paramsWithSsid;
}

@end
