import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:trakit/client/components/Input.dart';
import 'package:trakit/client/components/utils.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool estaVisible = false;

  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final telefonoController = TextEditingController();
  final nombreController = TextEditingController();

  final FocusNode titleFocus = FocusNode();
  final emailPattern = RegExp(r'^[\w-\.]+@unah\.edu\.hn$');
  final passwordPattern = RegExp(r'^(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$');
  final users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Cuenta'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 24),
            Input(label: 'Nombre Completo', controller: nombreController),
            SizedBox(height: 18),
            Input(
              label: 'Correo Electronico',
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 18),
            Input(
              label: 'Telefono',
              controller: telefonoController,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 24),
            Input(
              label: 'Contraseña',
              controller: passwordController,
              keyboardType: TextInputType.text,
              escondible: true,
            ),
            SizedBox(height: 18),
            ElevatedButton(
              child: Text('Crear Cuenta'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                if (nombreController.text.isEmpty) {
                  Utils.showSnackBar(
                    context: context,
                    title: "El nombre completo es obligatorio",
                    color: Colors.red,
                  );
                  return;
                }
                if (correoController.text.isEmpty) {
                  Utils.showSnackBar(
                    context: context,
                    title: "El correo electrónico es obligatorio",
                    color: Colors.red,
                  );
                  return;
                } else if (!emailPattern.hasMatch(correoController.text)) {
                  Utils.showSnackBar(
                    context: context,
                    title: "El correo debe ser institucional (.unah.edu.hn)",
                    color: Colors.red,
                  );
                  return;
                } else if (telefonoController.text.isEmpty) {
                  Utils.showSnackBar(
                    context: context,
                    title: "El teléfono es obligatorio",
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
                } else if (!passwordPattern.hasMatch(passwordController.text)) {
                  Utils.showSnackBar(
                    context: context,
                    title:
                        "La contraseña debe tener al menos 6 caracteres y un carácter especial",
                    color: Colors.red,
                  );
                  return;
                }
                // Crear usuario
                final newUser = {
                  'id': (users.length + 1).toString(),
                  'nombre': nombreController.text,
                  'correo': correoController.text,
                  'password': passwordController.text,
                };
                users.add(newUser);
                Utils.showSnackBar(
                  context: context,
                  title: "Usuario creado correctamente",
                  color: Colors.green,
                );

                context.pop();
              },
            ),
            SizedBox(height: 30),
            Text('O registrate con', style: TextStyle(color: Colors.grey[600])),
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
                  onPressed: () {},
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
                Text('¿Ya tienes una cuenta? '),
                TextButton(
                  onPressed: () {
                    //
                    context.goNamed('login');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // remove all padding
                    minimumSize: Size(0, 0), // optional: shrink minimum size
                    tapTargetSize: MaterialTapTargetSize
                        .shrinkWrap, // optional: shrink touch target
                  ),
                  child: Text('Inicia Sesión'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
