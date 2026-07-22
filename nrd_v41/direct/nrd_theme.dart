import 'package:flutter/material.dart';

abstract final class NrdColors {
  static const navy = Color(0xFF062E73);
  static const navyDeep = Color(0xFF031D50);
  static const blue = Color(0xFF0756BD);
  static const brightBlue = Color(0xFF1496E6);
  static const sky = Color(0xFF65C8F5);
  static const ice = Color(0xFFF4F8FE);
  static const ink = Color(0xFF0E2450);
  static const muted = Color(0xFF64748B);
  static const line = Color(0xFFDCE7F5);
  static const success = Color(0xFF1B9A5B);
}

ThemeData buildNrdTheme() {
  const scheme = ColorScheme.light(primary:NrdColors.blue,onPrimary:Colors.white,secondary:NrdColors.brightBlue,onSecondary:Colors.white,surface:Colors.white,onSurface:NrdColors.ink,error:Color(0xFFD64B4B),onError:Colors.white);
  const rounded = RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(14)));
  return ThemeData(
    useMaterial3:true,
    colorScheme:scheme,
    scaffoldBackgroundColor:NrdColors.ice,
    textTheme:const TextTheme(
      headlineLarge:TextStyle(fontWeight:FontWeight.w900,color:NrdColors.navy,letterSpacing:-1.2),
      headlineMedium:TextStyle(fontWeight:FontWeight.w900,color:NrdColors.navy,letterSpacing:-.7),
      headlineSmall:TextStyle(fontWeight:FontWeight.w800,color:NrdColors.navy),
      titleLarge:TextStyle(fontWeight:FontWeight.w800,color:NrdColors.navy),
      titleMedium:TextStyle(fontWeight:FontWeight.w700,color:NrdColors.ink),
      bodyLarge:TextStyle(height:1.45,color:NrdColors.ink),
      bodyMedium:TextStyle(height:1.42,color:NrdColors.ink),
      bodySmall:TextStyle(height:1.35,color:NrdColors.muted),
    ),
    cardTheme:CardThemeData(color:Colors.white,elevation:0,margin:EdgeInsets.zero,shape:rounded.copyWith(side:const BorderSide(color:NrdColors.line))),
    appBarTheme:const AppBarTheme(backgroundColor:Colors.white,foregroundColor:NrdColors.navy,surfaceTintColor:Colors.transparent,elevation:0,centerTitle:false,titleTextStyle:TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:NrdColors.navy)),
    navigationBarTheme:NavigationBarThemeData(backgroundColor:Colors.white,indicatorColor:const Color(0xFFE4F0FF),labelTextStyle:WidgetStateProperty.resolveWith((states)=>TextStyle(color:states.contains(WidgetState.selected)?NrdColors.blue:NrdColors.muted,fontWeight:states.contains(WidgetState.selected)?FontWeight.w800:FontWeight.w600,fontSize:11))),
    inputDecorationTheme:const InputDecorationTheme(filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(12)),borderSide:BorderSide(color:NrdColors.line)),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(12)),borderSide:BorderSide(color:NrdColors.line)),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(12)),borderSide:BorderSide(color:NrdColors.blue,width:1.5)),contentPadding:EdgeInsets.symmetric(horizontal:15,vertical:15),labelStyle:TextStyle(color:NrdColors.muted,fontWeight:FontWeight.w600)),
    filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(backgroundColor:NrdColors.blue,foregroundColor:Colors.white,shape:rounded,padding:const EdgeInsets.symmetric(horizontal:20,vertical:15),textStyle:const TextStyle(fontWeight:FontWeight.w800))),
    outlinedButtonTheme:OutlinedButtonThemeData(style:OutlinedButton.styleFrom(foregroundColor:NrdColors.blue,side:const BorderSide(color:Color(0xFFB8CEE9)),shape:rounded,padding:const EdgeInsets.symmetric(horizontal:20,vertical:14),textStyle:const TextStyle(fontWeight:FontWeight.w800))),
    dividerTheme:const DividerThemeData(color:NrdColors.line,thickness:1),
  );
}
