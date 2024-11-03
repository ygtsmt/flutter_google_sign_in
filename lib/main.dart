import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_sign_in/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GoogleSignInScreen(),
    );
  }
}

class GoogleSignInScreen extends StatefulWidget {
  @override
  _GoogleSignInScreenState createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  Future<User?> _signInWithGoogle() async {
    try {
      // Google Sign-In işlemini başlatıyoruz
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Kullanıcı iptal etti
        return null;
      }

      // Kimlik doğrulama bilgilerini alıyoruz
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase ile oturum açıyoruz
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Google ile giriş sırasında hata oluştu: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google ile Giriş"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final user = await _signInWithGoogle();
                if (user != null) {
                  // Giriş başarılı
                  setState(() {
                    _user = user;
                  });
                  print("Giriş yapıldı: ${user.displayName}");
                }
              },
              child: Text("Google ile Giriş Yap"),
            ),
            if (_user != null)
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _user?.multiFactor.unenroll();
                  });
                },
                child: Text("Çıkış yap"),
              ),
            if (_user != null) Text("Google ile Giriş Yapıldı"),
            if (_user != null)
              Column(
                children: [
                  Text(_user?.displayName ?? ''),
                  Text(_user?.email ?? ''),
                  Text(_user?.phoneNumber ?? 'ss'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    setState(() {});
  }
}
