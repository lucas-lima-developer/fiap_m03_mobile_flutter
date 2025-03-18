# fiap_m03_mobile_flutter

Este projeto é um aplicativo Flutter que utiliza Firebase para autenticação e armazenamento de dados.

## Requisitos

Antes de iniciar, certifique-se de ter instalado:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão >= 3.0.0)
- [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com/) com extensão Flutter/Dart
- [Java JDK 11+](https://www.oracle.com/java/technologies/javase-downloads.html) (para compilação no Android)
- [Firebase CLI](https://firebase.google.com/docs/cli) (opcional, para configuração avançada do Firebase)

## Configuração do Projeto

1. **Clone o repositório**

   ```sh
   git clone <URL_DO_REPOSITORIO>
   cd fiap_m03_mobile_flutter
   ```

2. **Instale as dependências**

   ```sh
   flutter pub get
   ```

3. **Configurar nova conta no Firebase**

   - Acesse o [Firebase Console](https://console.firebase.google.com/)
   - Entre com a nova conta desejada
   - Selecione o projeto existente ou crie um novo
   - Adicione um novo app Android ao projeto Firebase
   - Baixe o arquivo `google-services.json` e substitua o antigo dentro do diretório `android/app`
   - Para iOS, baixe o arquivo `GoogleService-Info.plist` e substitua no diretório `ios/Runner`
   - No terminal, execute:
     ```sh
     flutter clean
     flutter pub get
     ```

4. **Execute o projeto**
   - Conecte um dispositivo Android via USB ou inicie um emulador
   - Execute o comando:
     ```sh
     flutter run
     ```

## Build para Android

Para gerar um APK de produção:

```sh
flutter build apk --release
```

Para gerar um App Bundle (para publicar na Play Store):

```sh
flutter build appbundle
```

## Versões do Android

- **compileSdkVersion**: 35
- **minSdkVersion**: 23
- **targetSdkVersion**: 35

## Considerações

- Se houver erros com o Firebase, execute:
  ```sh
  flutter clean
  flutter pub get
  ```
- Se precisar depurar, utilize:
  ```sh
  flutter run --verbose
  ```
