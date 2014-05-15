#include <iostream>
#include <sstream>

#include <neu/nvar.h>
#include <neu/NProgram.h>
#include <neu/NObject.h>
#include <neu/NMLParser.h>
#include <neu/NMLGenerator.h>

using namespace std;
using namespace neu;

// this is a C++ class in which we expose its methods to the
// interpreter using the neu-meta command (see the Makefile)
class CPPObject : public NObject{
public:

  CPPObject()
    : multiplier_(1){
    
  }

  nvar product(const nvar& v){
    nvar ret = multiplier_;
    
    for(size_t i = 0; i < v.size(); ++i){
      ret *= v[i];
    }
    
    return ret;
  }

  // to interpret this method, parameters don't necessarly have to be
  // of type nvar - but N-compatible, i.e: it must possible to
  // construct an nvar with them
  int add(int x, int y){
    return x + y;
  }

  // the handle method implementation will be auto-generated by
  // neu-meta but we need this prototype
  NFunc handle(const nvar& n, uint32_t flags=0);

private:
  int multiplier_;
};

// include the neu-meta generated code
#ifndef META_GUARD
#include "CPPObject_meta.h"
#endif

int main(int argc, char** argv){
  NProgram program(argc, argv);

  NMLParser parser;
  // parse the NML code into N code
  nvar code = parser.parseFile("test.nml");

  cout << "code is: " << code << endl;

  // reconstruct the NML code from N code (just for demonstration
  // purposes)
  NMLGenerator generator;
  stringstream sstr;
  generator.generate(sstr, code);
  cout << "------------- reconstructed NML" << endl;
  cout << sstr.str() << endl;

  // execute the code we parsed
  NObject interpreter;
  interpreter.process(code);

  return 0;
}
