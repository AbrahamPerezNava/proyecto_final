import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_final/sources/app.dart';
import 'package:proyecto_final/sources/bloc/auth_cubit.dart';
import 'package:proyecto_final/sources/repository/implementacion/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authCubit = AuthCubit(AuthRepository());
  runApp(
    BlocProvider(
      create: (_) => authCubit..init(),
      child: MyApp.create(),
    ),
  );
}
