import 'package:flutter/foundation.dart';

import '../../core/utils/device_identity.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/google_auth_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/forgot_password.dart';
import 'domain/usecases/login.dart';
import 'domain/usecases/logout.dart';
import 'domain/usecases/refresh_token.dart';
import 'domain/usecases/register.dart';
import 'domain/usecases/resend_verification.dart';
import 'domain/usecases/reset_password.dart';
import 'domain/usecases/verify_email.dart';

class AuthDependencies {
  AuthDependencies._();

  static final AuthRemoteDataSource remoteDataSource =
  AuthRemoteDataSourceImpl();

  static final GoogleAuthDataSource googleAuthDataSource =
  GoogleAuthDataSource(
    serverClientId: const String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
    ),
  );

  static final AuthRepositoryImpl repository =
  AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );

  static final Login login =
  Login(repository);

  static final Register register =
  Register(repository);

  static final VerifyEmail verifyEmail =
  VerifyEmail(repository);

  static final ResendVerification resendVerification =
  ResendVerification(repository);

  static final ForgotPassword forgotPassword =
  ForgotPassword(repository);

  static final ResetPassword resetPassword =
  ResetPassword(repository);

  static final RefreshToken refreshToken =
  RefreshToken(repository);

  static final Logout logout =
  Logout(repository);

  static Future<void> loginWithGoogle() async {
    final idToken =
    await googleAuthDataSource
        .signInAndGetIdToken();

    final deviceUuid =
    await DeviceIdentity.getDeviceUuid();

    final deviceType =
    defaultTargetPlatform ==
        TargetPlatform.iOS
        ? 'ios'
        : 'android';

    await repository.loginWithGoogle(
      idToken: idToken,
      deviceUuid: deviceUuid,
      deviceType: deviceType,
    );
  }
}