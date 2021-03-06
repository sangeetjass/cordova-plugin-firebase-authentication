#import "FirebaseAuthenticationPlugin.h"

@import FirebaseAuth;


@implementation FirebaseAuthenticationPlugin

- (void)getIdToken:(CDVInvokedUrlCommand *)command {
    BOOL forceRefresh = [[command.arguments objectAtIndex:0] boolValue];

    [self.commandDelegate runInBackground: ^{
        FIRUser *user = [FIRAuth auth].currentUser;

        if (user) {
            [user getIDTokenForcingRefresh:forceRefresh completion:^(NSString *token, NSError *error) {
                CDVPluginResult *pluginResult;
                if (error) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:token];
                }

                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        } else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User must be signed in"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)signInWithEmailAndPassword:(CDVInvokedUrlCommand *)command {
    NSString* email = [command.arguments objectAtIndex:0];
    NSString* password = [command.arguments objectAtIndex:1];

    [self.commandDelegate runInBackground: ^{
        [[FIRAuth auth] signInWithEmail:email
                               password:password
                             completion:^(FIRUser *user, NSError *error) {
            CDVPluginResult *pluginResult;
            if (error) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self userToDictionary:user]];
            }

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)signInWithVerificationId:(CDVInvokedUrlCommand*)command {
    NSString* verificationId = [command.arguments objectAtIndex:0];
    NSString* smsCode = [command.arguments objectAtIndex:1];

    [self.commandDelegate runInBackground: ^{
        FIRAuthCredential *credential = [[FIRPhoneAuthProvider provider]
                credentialWithVerificationID:verificationId
                            verificationCode:smsCode];

        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
            CDVPluginResult *pluginResult;
            if (error) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self userToDictionary:user]];
            }

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)verifyPhoneNumber:(CDVInvokedUrlCommand*)command {
    NSString* phoneNumber = [command.arguments objectAtIndex:0];

    [self.commandDelegate runInBackground: ^{
        [[FIRPhoneAuthProvider provider] verifyPhoneNumber:phoneNumber
                                                completion:^(NSString* verificationId, NSError* error) {
            CDVPluginResult *pluginResult;
            if (error) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:verificationId];
            }

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }];
}

- (void)signOut:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        NSError *signOutError;
        BOOL status = [[FIRAuth auth] signOut:&signOutError];
        CDVPluginResult *pluginResult;
        if (status) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:signOutError.localizedDescription];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (NSDictionary*)userToDictionary:(FIRUser *)user {
    return @{
        @"uid": user.uid,
        @"providerId": user.providerID,
        @"displayName": user.displayName ? user.displayName : @"",
        @"email": user.email ? user.email : @"",
        @"phoneNumber": user.phoneNumber ? user.phoneNumber : @"",
        @"photoURL": user.photoURL ? user.photoURL.absoluteString : @""
    };
}

@end
