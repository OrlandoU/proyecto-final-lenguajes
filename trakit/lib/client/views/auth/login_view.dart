import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:trakit/client/components/input.dart';
import 'package:trakit/client/components/utils.dart';
import 'package:trakit/src/firebase/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.todo});

  final Map<String, dynamic>? todo;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool estaVisible = false;
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  final FocusNode titleFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 24),
            Input(
              label: 'Correo Electronico',
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 18),
            Input(
              label: 'Contraseña',
              controller: passwordController,
              keyboardType: TextInputType.text,
              escondible: true,
            ),

            SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                if (correoController.text.isEmpty) {
                  Utils.showSnackBar(
                    context: context,
                    title: "El correo electrónico es obligatorio",
                    color: Colors.red,
                  );
                  return;
                } else if (passwordController.text.isEmpty) {
                  Utils.showSnackBar(
                    context: context,
                    title: "La contraseña es obligatoria",
                    color: Colors.red,
                  );
                  return;
                }

                if (correoController.text != 'orlando.umanzor@unah.hn' ||
                    passwordController.text != '20232001355') {
                  Utils.showSnackBar(
                    context: context,
                    title: "Correo o contraseña incorrecta",
                    color: Colors.red,
                  );
                  return;
                }

                Utils.showSnackBar(
                  context: context,
                  title: "Inicio de sesión exitoso",
                  color: Colors.green,
                );

                context.pop();
              },
              child: Text('Iniciar Sesión'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text('O ingresa con', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const FaIcon(
                    FontAwesomeIcons.facebookF,
                    color: Colors.blue,
                  ),
                  style: IconButton.styleFrom(backgroundColor: Colors.blue[50]),
                ),
                IconButton(
                  onPressed: ()async{
                    try {
                      final user = await signInWithGoogle();

                      if (user != null && context.mounted) {
                        createUser();
                        context.push('/');
                      }
                    } catch (e) {
                      print(e);
                    }

                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.red,
                  ),
                  style: IconButton.styleFrom(backgroundColor: Colors.red[50]),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const FaIcon(
                    FontAwesomeIcons.twitter,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿No tienes una cuenta? '),
                TextButton(
                  onPressed: () {
                    //
                    context.goNamed('signup');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // remove all padding
                    minimumSize: Size(0, 0), // optional: shrink minimum size
                    tapTargetSize: MaterialTapTargetSize
                        .shrinkWrap, // optional: shrink touch target
                  ),
                  child: Text('Crear una cuenta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
