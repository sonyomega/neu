%option noyywrap

%{
  
  /*================================= Neu =================================
   
   Copyright (c) 2013-2014, Andrometa LLC
   All rights reserved.
   
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:
   
   1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
   
   2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
   
   3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.
   
   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
   
   =======================================================================*/
  
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  
  #include <iostream>
  
  #include "NPLParser_.h"
  #include "parse.tab.h"
  #include "parse.h"
  
  #define PS yyget_extra(yyscanner)
  
  #if defined (__i386__) || defined (__APPLE__)
  
  #define M_INTEGER_MAX 9223372036854775807LL
  
  #else
  
  #define M_INTEGER_MAX 9223372036854775807L
  
  #endif
  
  using namespace std;
  using namespace neu;
  
  static size_t precision(const nstr& s){
    size_t count = 0;
    bool past = false;
    
    for(size_t i = 0; i < s.size(); ++i){
      if(s[i] == '0'){
        if(past){
          ++count;
        }
      }
      else if(nstr::isDigit(s[i])){
        ++count;
        past = true;
      }
    }
    
    return count;
  }
	
%}

%option reentrant bison-bridge
%option always-interactive

COMMENT "//".+\n
MULTILINE_COMMENT "/*"[^"*/"]*"*/"
IDENTIFIER ([a-zA-Z])|(_+[a-zA-Z][a-zA-Z0-9_]*)|([a-zA-Z][a-zA-Z0-9_]*)
INTEGER [0-9]+
DOUBLE (([0-9]+\.[0-9]+)|(\.[0-9]+)|([0-9]+))([Ee][\+\-]?[0-9]+)?
STRING_LITERAL \"([^\"]|\\\")*\"
STRING_LITERAL_SQ	\'([^\']|\\\')*\'
EQ "=="
NE "!="
GE ">="
LE "<="
ADD_BY "+="
SUB_BY "-="
INC "++"
DEC "--"
MUL_BY "*="
DIV_BY "/="
MOD_BY "%="
AND "&&"
OR  "||"
KW_TRUE true
KW_FALSE false
KW_VOID void
KW_FOR for
KW_IF if
KW_ELSE else
KW_WHILE while
KW_RETURN return
KW_BREAK break
KW_CONTINUE continue
KW_CLASS class
TYPE (bool)|(char)|(short)|(int)|(long)|(float)|(double)
VEC_TYPE (bool[0-9]+)|(char[0-9]+)|(short[0-9]+)|(int[0-9]+)|(long[0-9]+)|(float[0-9]+)|(double[0-9]+)
DEFINE "#define"

%%

{COMMENT} {
  PS->newLine(1);
  PS->advance(yytext, "comment");
}

{MULTILINE_COMMENT} {
  PS->newLine(nstr(yytext).findCount("\n"));
  PS->advance(yytext, "comment");
}

{EQ} {
  PS->advance(yytext, "operator");
  return EQ;
}

{NE} {
  PS->advance(yytext, "operator");
  return NE;
}

{GE} {
  PS->advance(yytext, "operator");
  return GE;
}

{LE} {
  PS->advance(yytext, "operator");
  return LE;
}

{INC} {
  PS->advance(yytext, "operator");
  return INC;
}

{DEC} {
  PS->advance(yytext, "operator");
  return DEC;
}

{ADD_BY} {
  PS->advance(yytext, "operator");
  return ADD_BY;
}

{SUB_BY} {
  PS->advance(yytext, "operator");
  return SUB_BY;
}

{MUL_BY} {
  PS->advance(yytext, "operator");
  return MUL_BY;
}

{DIV_BY} {
  PS->advance(yytext, "operator");
  return DIV_BY;
}

{MOD_BY} {
  PS->advance(yytext, "operator");
  return MOD_BY;
}

{AND} {
  PS->advance(yytext, "operator");
  return AND;
}

{OR} {
  PS->advance(yytext, "operator");
  return OR;
}

{KW_TRUE} {
  PS->advance(yytext, "keyword");
  return KW_TRUE;
}

{KW_FALSE} {
  PS->advance(yytext, "keyword");
  return KW_FALSE;
}

{KW_VOID} {
  PS->advance(yytext, "keyword");
  return KW_VOID;
}

{KW_FOR} {
  PS->advance(yytext, "keyword");
  return KW_FOR;
}

{KW_IF} {
  PS->advance(yytext, "keyword");
  return KW_IF;
}

{KW_ELSE} {
  PS->advance(yytext, "keyword");
  return KW_ELSE;
}

{KW_WHILE} {
  PS->advance(yytext, "keyword");
  return KW_WHILE;
}

{KW_RETURN} {
  PS->advance(yytext, "keyword");
  return KW_RETURN;
}

{KW_BREAK} {
  PS->advance(yytext, "keyword");
  return KW_BREAK;
}

{KW_CONTINUE} {
  PS->advance(yytext, "keyword");
  return KW_CONTINUE;
}

{KW_CLASS} {
  PS->advance(yytext, "keyword");
  return KW_CLASS;
}

{DEFINE} {
  PS->advance(yytext, "keyword");
  return DEFINE;
}

{INTEGER} {
  nreal r(yytext);
  PS->advance(yytext, "numeric");
  yylval->v = r.toLong();
  return INTEGER;
}

{DOUBLE} {
  nstr s = yytext;
  PS->advance(yytext, "numeric");
  double d;
  sscanf(yytext, "%lf", &d);
  yylval->v = d;
  return DOUBLE;
}

{TYPE} {
  PS->advance(yytext, "type");
  
  nstr t = yytext;
  t.uppercase();
  yylval->v = PS->func(t);
  return TYPE;
}

{VEC_TYPE} {
  PS->advance(yytext, "type");
  
  nstr t = yytext;
  
  size_t i;
  size_t len = t.length();
  for(i = 0; i < len; ++i){
    if(nstr::isDigit(t[i])){
      break;
    }
  }
  
  size_t n = atoi(t.substr(i, len - i).c_str());
  t = t.substr(0, i);
  t.uppercase();
  
  yylval->v = PS->func(t) << nvar(i);
  
  return TYPE;
}

{IDENTIFIER} {
  yylval->v = PS->token(yytext);
  return IDENTIFIER;
}

{STRING_LITERAL} {
  yylval->v = yytext;
  nstr& s = yylval->v;
  s.erase(0, 1);
  s.erase(s.length() - 1, 1);
  PS->advance(yytext, "string");
  return STRING_LITERAL;
}

{STRING_LITERAL_SQ} {
  yylval->v = yytext;
  nstr& s = yylval->v;
  s.erase(0, 1);
  s.erase(s.length() - 1, 1);
  PS->advance(yytext, "string");
  return STRING_LITERAL;
}

[\+\-\/\%\*\,\.\;\=\<\>\:\!\|\^\{\}\[\]\(\)\@] {
  PS->advance(1, "operator");
  return *yytext;
}

[\n] {
  PS->newLine();
}

[ \t] { PS->advance(1); }

. { 
  nstr msg = nstr("invalid character: '") + yytext + "'";
  npl_error(PS, yyscanner, msg.c_str());
}

%%