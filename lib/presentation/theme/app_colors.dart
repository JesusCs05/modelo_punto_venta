// Archivo: lib/presentation/theme/app_colors.dart
import 'package:flutter/material.dart';

/*
 * Guía de Estilos Visuales (Paleta "Innovación Púrpura")
 * Basado en el color semilla #62065f.
 */
class AppColors {
  // --- Colores de la paleta (Referencia) ---
  
  // El color base solicitado: Púrpura Profundo / Ciruela
  static const Color paletteDeepPurple = Color(0xFF62065F); 
  
  // Complemento vibrante para botones de acción: Coral Neón / Naranja Rojizo
  // (El naranja/coral contrasta perfectamente con el púrpura y mantiene la energía "Ágil")
  static const Color paletteVibrantCoral = Color(0xFFFF6B6B); 
  
  // Neutro oscuro para textos: Carbón Violáceo
  static const Color paletteDarkCharcoal = Color(0xFF2D242C); 
  
  // Fondo: Blanco Lavanda (Muy sutil, menos clínico que el gris, más cálido)
  static const Color paletteLavenderMist = Color(0xFFF9F7FA); 
  
  // Secundario: Gris Pizarra con tinte lila
  static const Color paletteSlateLilac = Color(0xFF8C7D8F);
  
  static const Color paletteWhite = Color(0xFFFFFFFF);
  
  // --- Roles Funcionales de la App ---

  /// Fondo Principal: #F9F7FA (Blanco Lavanda)
  /// Un fondo limpio que armoniza con el púrpura sin cansar la vista.
  static const Color background = paletteLavenderMist;

  /// Primario / Éxito: #62065F (Púrpura Profundo)
  /// Usado para la barra superior, login y confirmaciones estándar ("SÍ").
  /// Transmite robustez y elegancia.
  static const Color primary = paletteDeepPurple;

  /// Acento / CTA / Peligro: #FF6B6B (Coral Vibrante)
  /// Usado para el botón principal ("COBRAR") y alertas.
  /// Es un color de "Alta Velocidad" que destaca inmediatamente sobre el púrpura.
  static const Color accentCta = paletteVibrantCoral;

  /// Secundario / Acento Frío: #8C7D8F (Gris Pizarra Lila)
  /// Usado para botones secundarios ("Cancelar Venta", "Recibir Envases").
  static const Color secondary = paletteSlateLilac;

  /// Resaltado / Información: #62065F (Mismo que primario o una variante más clara)
  static const Color highlight = paletteDeepPurple;

  // --- Colores de Texto ---
  
  /// Texto Principal: #2D242C (Carbón Oscuro)
  /// Máxima legibilidad sobre el fondo claro.
  static const Color textPrimary = paletteDarkCharcoal;

  /// Texto Invertido: #FFFFFF (Blanco)
  /// Para usar sobre el Púrpura (#62065F) y el Coral (#FF6B6B).
  static const Color textInverted = paletteWhite;
  
  /// Fondo de Tarjetas/Listas (Blanco Puro)
  static const Color cardBackground = paletteWhite;
}