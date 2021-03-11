import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_credo/core/constant/string_constants.dart';
import 'package:flutter_credo/core/errors/credo_exceptions.dart';
import 'package:flutter_credo/core/network/http_service_requester.dart';
import 'package:flutter_credo/core/utils/util.dart';
import 'package:flutter_credo/src/data/data_source/remote_datasource.dart';
import 'package:flutter_credo/src/data/models/init_payment_response_model.dart';
import 'package:flutter_credo/src/data/models/third_party_payment_response_model.dart';
import 'package:flutter_credo/src/data/models/verify_card_response_model.dart';
import 'package:flutter_credo/src/data/models/verify_transaction_response.dart';
import 'package:meta/meta.dart';

class CredoSdkRepository {
  CredoRemoteDataSource credoRemoteDataSource;

  CredoSdkRepository() {
    this.credoRemoteDataSource = CredoRemoteDataSourceImpl(
      HttpServiceRequester(),
    );
  }

  Future<Either<CredoException, InitPaymentResponseModel>> initialPayment({
    @required double amount,
    @required String currency,
    String redirectUrl,
    String transactionRef,
    String paymentOptions,
    @required String customerEmail,
    @required String customerName,
    @required String customerPhoneNo,
    @required String publicKey,
  }) async {
    try {
      InitPaymentResponseModel initPaymentResponseModel =
          await credoRemoteDataSource.initialPayment(
        amount: amount,
        currency: currency,
        transactionRef: transactionRef ?? Utils.getRandomString(),
        paymentOptions: paymentOptions,
        customerEmail: customerEmail,
        customerName: customerName,
        publicKey: publicKey,
        customerPhoneNo: customerPhoneNo,
        redirectUrl: redirectUrl,
      );
      return Right(initPaymentResponseModel);
    } catch (e) {
      if (e is DioError) {
        return Left(
          CredoException(
            message: InitPaymentResponseModel.fromErrorMap(
              e.response.data,
            ).message,
          ),
        );
      }
      return Left(
        CredoException(
          message: StringConstants.sthWentWrong,
        ),
      );
    }
  }

  Future<Either<CredoException, ThirdPartyPaymentResponse>> checkOut({
    @required String orderCurrency,
    @required String cardNumber,
    @required String expiryMonth,
    @required String expiryYear,
    @required String securityCode,
    @required String transRef,
    String customerEmail,
    String customerName,
    String customerPhoneNo,
    @required String paymentSlug,
    @required String secretKey,
    double orderAmount,
  }) async {
    try {
      VerifyCardResponseModel verifyCardResponseModel =
          await credoRemoteDataSource.verifyCardDetails(
        cardNumber: cardNumber,
        orderCurrency: orderCurrency,
        paymentSlug: paymentSlug,
        secretKey: secretKey,
      );

      if (verifyCardResponseModel.gatewayRecommendation != 'PROCEED') {
        throw CardException('Please confirm your card number and try again..');
      }

      ThirdPartyPaymentResponse thirdPartyPaymentResponse =
          await credoRemoteDataSource.thirdPartyPay(
        orderCurrency: orderCurrency,
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        securityCode: securityCode,
        transRef: transRef,
        customerEmail: customerEmail,
        customerName: customerName,
        customerPhoneNo: customerPhoneNo,
        paymentSlug: paymentSlug,
        orderAmount: orderAmount,
        secretKey: secretKey,
      );
      return Right(thirdPartyPaymentResponse);
    } catch (e) {
      if (e is DioError) {
        return Left(
          CredoException(
            message: ThirdPartyPaymentResponse.fromErrorMap(
              e.response.data,
            ).message,
          ),
        );
      } else if (e is CredoException) {
        return Left(e);
      }
      return Left(
        CredoException(
          message: StringConstants.sthWentWrong,
        ),
      );
    }
  }

  Future<Either<CredoException, VerifyCardResponseModel>> verifyCard({
    @required String cardNumber,
    @required String orderCurrency,
    @required String paymentSlug,
    @required String secretKey,
  }) async {
    try {
      VerifyCardResponseModel verifyCardResponseModel =
          await credoRemoteDataSource.verifyCardDetails(
        cardNumber: cardNumber,
        orderCurrency: orderCurrency,
        paymentSlug: paymentSlug,
        secretKey: secretKey,
      );
      return Right(verifyCardResponseModel);
    } catch (e) {
      if (e is DioError) {
        return Left(
          CredoException(
            message: VerifyCardResponseModel.fromErrorMap(
              e.response.data,
            ).message,
          ),
        );
      }
      return Left(
        CredoException(
          message: StringConstants.sthWentWrong,
        ),
      );
    }
  }

  Future<Either<CredoException, VerifyTransactionResponseModel>>
      verifyTransaction({
    @required String transactionRef,
    @required String secretKey,
  }) async {
    try {
      VerifyTransactionResponseModel verifyTransactionResponseModel =
          await credoRemoteDataSource.verifyTransaction(
        transactionRef: transactionRef,
        secretKey: secretKey,
      );
      return Right(verifyTransactionResponseModel);
    } catch (e) {
      if (e is DioError) {
        return Left(
          CredoException(
            message: VerifyTransactionResponseModel.fromErrorMap(
              e.response.data,
            ).message,
          ),
        );
      }
      return Left(
        CredoException(
          message: StringConstants.sthWentWrong,
        ),
      );
    }
  }
}