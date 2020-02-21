/**
 *  Java Grinder
 *  Author: Michael Kohn
 *   Email: mike@mikekohn.net
 *     Web: http://www.naken.cc/
 * License: GPL
 *
 * Copyright 2014-2016 by Michael Kohn
 *
 */

/*
 *   Lionsys Theodoulos Liontakis
 */

package net.mikekohn.java_grinder;

abstract public class Lionsys
{

  protected Lionsys() { }

  public static void cls() { }
  public static void beep() { }
  public static void color(byte foreground, byte background, byte border) { }
  public static void screen(byte mode) { }
  public static void width(byte w) { }
  public static void keyOn() { }
  public static void keyOff() { }
  public static void fillVRAM(int c, int len, int addr) { }
  public static void copyVRAM(int len, int source, int dest) { }
  public static void putChar(char c) { }
  public static void putChar(int y, int x, char c) { }
  public static void setCursor(byte column, byte line) { }
}
