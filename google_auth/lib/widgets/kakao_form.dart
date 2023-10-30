import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

class KakaoForm extends StatelessWidget {
  const KakaoForm({super.key});

  @override
  Widget build(BuildContext context) {
    void login() async {
      kakao.User? kakaoUser = await kakao.UserApi.instance.me();

      print("kakao id : ${kakaoUser.id}");
    }

    return ElevatedButton(
      onPressed: () async {
        if (await kakao.isKakaoTalkInstalled()) {
          try {
            await kakao.UserApi.instance.loginWithKakaoTalk();
            login();
          } catch (error) {
            print('카카오톡으로 로그인 실패 $error');

            // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
            // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
            if (error is PlatformException && error.code == 'CANCELED') {
              return;
            }
            // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
            try {
              await kakao.UserApi.instance.loginWithKakaoAccount();
              login();
            } catch (error) {
              print('카카오계정으로 로그인 실패 $error');
            }
          }
        } else {
          try {
            await kakao.UserApi.instance.loginWithKakaoAccount();
            login();
          } catch (error) {
            print('카카오계정으로 로그인 실패 $error');
          }
        }
      },
      child: const Text(
        "Kakao Login",
      ),
    );
  }
}
