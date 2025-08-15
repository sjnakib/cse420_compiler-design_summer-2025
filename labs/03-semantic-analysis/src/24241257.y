%{

#include "symbol_table.h"
#include <unordered_set>
using namespace std;
#define YYSTYPE symbol_info*

extern FILE *yyin;
int yyparse(void);
int yylex(void);
extern YYSTYPE yylval;

// create your symbol table here.
// You can store the pointer to your symbol table in a global variable
// or you can create an object
symbol_table* main_table;
int lines = 1;
int errors = 0;

ofstream outlog;
ofstream outlog2;


// you may declare other necessary variables here to store necessary info
vector<string> split(const string& str, char delim) {
    vector<string> tokens;
    stringstream ss(str);
    string token;
    while (getline(ss, token, delim)) {
        tokens.push_back(token);
    }
    return tokens;
}

bool isInteger(const std::string& s) {
    std::istringstream iss(s);
    int i;
    char c;
    return (iss >> i) && !(iss >> c);  // Succeeds if fully convertible to int
}

bool isFloat(const std::string& s) {
    std::istringstream iss(s);
    float f;
    char c;
    return (iss >> f) && !(iss >> c);  // Succeeds if fully convertible to float
}

string type_conversion(string x) {

    if (isInteger(x)) {
		return "int";
    } else if (isFloat(x)) {
		return "float";
    } else {
        return "ID";
    }
}


// such as current variable type, variable list, function name, return type, function parameter types, parameters names etc.
string symbol_type;
string data_type;
int array_size;
vector<string> parameter_types, parameter_names;

void yyerror(char *s)
{
	outlog<<"At line "<<lines<<" "<<s<<endl<<endl;

    // you may need to reinitialize variables if you find an error
}

%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
		outlog<<"Symbol Table"<<endl<<endl;

		// Print your whole symbol table here
		main_table->print_all_scopes(outlog);
	}
	;

program : program unit
	{
		outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
		outlog<<$1->get_name()+"\n"+$2->get_name()<<endl<<endl;

		$$ = new symbol_info($1->get_name()+"\n"+$2->get_name(),"program");
	}
	| unit
	{
		outlog<<"At line no: "<<lines<<" program : unit "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;

		$$ = new symbol_info($1->get_name(),"program");
	}
	;

unit : var_declaration
	 {
		outlog<<"At line no: "<<lines<<" unit : var_declaration "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;

		$$ = new symbol_info($1->get_name(),"unit");
	 }
     | func_definition
     {
		outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;

		$$ = new symbol_info($1->get_name(),"unit");
	 }
     ;

func_definition : type_specifier ID LPAREN parameter_list RPAREN

{

	// Check if a function name ID exists in the same scope
			auto result = main_table->lookup($2,0);
			if (result != nullptr) {
				outlog2 << "At line no: " << lines << " Multiple declaration of function " << $2->get_name() << endl<<endl;
				outlog << "At line no: " << lines << " Multiple declaration of function " << $2->get_name() << endl<<endl;
				errors++;

			}



	symbol_info* new_symbol = new symbol_info($2->get_name(), $2->get_type(), "Function Definition", $4->get_param_types(), $4->get_param_names());
	new_symbol->set_data_type($1->get_name());
	main_table->insert(new_symbol);









	// Check for multiple parameters with same name
	auto param = $4->get_param_names();
	std::unordered_set<std::string> seen;
	for (const auto& name : param) {
		if (seen.count(name)) {
			outlog2 << "At line no: " << lines << " Multiple declaration of variable " << name << " in parameter of " << $2->get_name() << endl<<endl;
			outlog << "At line no: " << lines << " Multiple declaration of variable " << name << " in parameter of " << $2->get_name() << endl<<endl;
			errors++;
		} else {
			seen.insert(name);
		}
	}



	main_table->enter_scope();
	outlog << "New ScopeTable with ID " << main_table->getCurrentScopeID() << " created" << endl << endl;

	// Loop here
	auto param_types = $4->get_param_types();
	auto param_names = $4->get_param_names();


	if (param_types.size() == param_names.size()) {
		for (size_t i = 0; i < param_types.size(); ++i) {
			symbol_info* param_symbol = new symbol_info(param_names[i], "ID", "Variable");
			param_symbol->set_data_type(param_types[i]);  // Set the correct type
			main_table->insert(param_symbol);
		}
	}
}



compound_statement
		{
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<"("+$4->get_name()+")\n"<<$7->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+" "+$2->get_name()+"("+$4->get_name()+")\n"+$7->get_name(),"func_def");

			// The function definition is complete.
            // You can now insert necessary information about the function into the symbol table
            // However, note that the scope of the function and the scope of the compound statement are different.


		}

		| type_specifier ID LPAREN RPAREN
		{

			symbol_info* new_symbol = new symbol_info($2->get_name(), $2->get_type(), "Function Definition");
			new_symbol->set_data_type($1->get_name());
			main_table->insert(new_symbol);

			main_table->enter_scope();
			outlog << "New ScopeTable with ID " << main_table->getCurrentScopeID() << " created" << endl << endl;


		}

		compound_statement
		{
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<"()\n"<<$6->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+" "+$2->get_name()+"()\n"+$6->get_name(),"func_def");

			// The function definition is complete.
            // You can now insert necessary information about the function into the symbol table
            // However, note that the scope of the function and the scope of the compound statement are different.
		}
 		;

parameter_list : parameter_list COMMA type_specifier ID
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier ID "<<endl<<endl;
			outlog<<$1->get_name()<<","<<$3->get_name()<<" "<<$4->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+","+$3->get_name()+" "+$4->get_name(),"param_list");

            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
			$$->set_param_types($1->get_param_types());
    		$$->set_param_names($1->get_param_names());
    		$$->add_parameter($3->get_name(), $4->get_name());
		}

		| parameter_list COMMA type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier "<<endl<<endl;
			outlog<<$1->get_name()<<","<<$3->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+","+$3->get_name(),"param_list");

            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
    		$$->set_param_types($1->get_param_types());
    		$$->set_param_names($1->get_param_names());
    		$$->add_parameter($3->get_name(), "");
		}
 		| type_specifier ID
 		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier ID "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+" "+$2->get_name(),"param_list");

            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
			$$->add_parameter($1->get_name(), $2->get_name());
		}
		| type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name(),"param_list");

            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
			$$->add_parameter($1->get_name(), "");
		}
 		;

compound_statement : LCURL statements RCURL
			{
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL statements RCURL "<<endl<<endl;
				outlog<<"{\n"+$2->get_name()+"\n}"<<endl<<endl;

				$$ = new symbol_info("{\n" + $2->get_name() + "\n}","comp_stmnt");

                // The compound statement is complete.
                // Print the symbol table here and exit the scope
                // Note that function parameters should be in the current scope
				main_table->print_all_scopes(outlog);
				int id = main_table->getCurrentScopeID();
    			main_table->exit_scope();
				outlog << "Scopetable with ID " << id << " removed" << endl << endl;

 		    }
 		    | LCURL RCURL
 		    {
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL RCURL "<<endl<<endl;
				outlog<<"{\n}"<<endl<<endl;

				$$ = new symbol_info("{\n}","comp_stmnt");

				// The compound statement is complete.
                // Print the symbol table here and exit the scope
				main_table->print_all_scopes(outlog);
				int id = main_table->getCurrentScopeID();
    			main_table->exit_scope();
				outlog << "Scopetable with ID " << id << " removed" << endl << endl;
 		    }
 		    ;

var_declaration : type_specifier declaration_list SEMICOLON  // int a,b,c,d;
		 {
			// Void type variable not allowed
			if($1->get_name() == "void")
			{
				outlog2<<"At line no: "<<lines<<" variable type can not be void"<<endl<<endl;
				outlog<<"At line no: "<<lines<<" variable type can not be void"<<endl<<endl;
				errors++;
			}


			outlog<<"At line no: "<<lines<<" var_declaration : type_specifier declaration_list SEMICOLON "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<";"<<endl<<endl;

			$$ = new symbol_info($1->get_name()+" "+$2->get_name()+";","var_dec");

			// Insert necessary information about the variables in the symbol table
		 	data_type = $1->get_name();
			//symbol_type="Variable";
    		vector<string> vars = split($2->get_name(), ',');

			for (const string& var : vars) {
				size_t open_bracket = var.find('[');
				size_t close_bracket = var.find(']');

				if (open_bracket != string::npos && close_bracket != string::npos && close_bracket > open_bracket + 1) {

					string array_name = var.substr(0, open_bracket);
					string size_str = var.substr(open_bracket + 1, close_bracket - open_bracket - 1);
					int array_size = stoi(size_str);


					symbol_info* new_symbol = new symbol_info(array_name, "ID", "Array");
					// Check if this new variable name exists in the current scope
					auto result = main_table->lookup(new_symbol,0);
					if (result != nullptr) {
						outlog2 << "At line no: " << lines << " Multiple declaration of variable " << array_name << endl<<endl;
						outlog << "At line no: " << lines << " Multiple declaration of variable " << array_name << endl<<endl;
						errors++;
					}
					new_symbol->set_array_size(array_size);
					new_symbol->set_data_type(data_type);
					main_table->insert(new_symbol);
				} else {
					// Normal variable
					symbol_info* new_symbol = new symbol_info(var, "ID", "Variable");

					// Check if this new variable name exists in the current scope
					auto result = main_table->lookup(new_symbol,0);
					if (result != nullptr) {
						outlog2 << "At line no: " << lines << " Multiple declaration of variable " << var << endl<<endl;
						outlog << "At line no: " << lines << " Multiple declaration of variable " << var << endl<<endl;
						errors++;
					}

					new_symbol->set_data_type(data_type);
					main_table->insert(new_symbol);
				}
			}
		 };

type_specifier : INT
		{
			outlog<<"At line no: "<<lines<<" type_specifier : INT "<<endl<<endl;
			outlog<<"int"<<endl<<endl;

			$$ = new symbol_info("int","type");
	    }
 		| FLOAT
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : FLOAT "<<endl<<endl;
			outlog<<"float"<<endl<<endl;

			$$ = new symbol_info("float","type");
	    }
 		| VOID
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : VOID "<<endl<<endl;
			outlog<<"void"<<endl<<endl;

			$$ = new symbol_info("void","type");
	    }
 		;

declaration_list : declaration_list COMMA ID
		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID "<<endl<<endl;
 		  	outlog<<$1->get_name()+","<<$3->get_name()<<endl<<endl;

            // you may need to store the variable names to insert them in symbol table here or later
			$$ = new symbol_info($1->get_name() + "," + $3->get_name(), "declaration_list");
 		  }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD //array after some declaration
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
 		  	outlog<<$1->get_name()+","<<$3->get_name()<<"["<<$5->get_name()<<"]"<<endl<<endl;
			symbol_type="Array";
			array_size = stoi($5->get_name());
            // you may need to store the variable names to insert them in symbol table here or later
			$$ = new symbol_info($1->get_name() + "," + $3->get_name() + "[" + $5->get_name() + "]", "declaration_list");
 		  }
 		  |ID
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

            // you may need to store the variable names to insert them in symbol table here or later
			$$ = new symbol_info($1->get_name(), "declaration_list");
 		  }
 		  | ID LTHIRD CONST_INT RTHIRD //array
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
			outlog<<$1->get_name()<<"["<<$3->get_name()<<"]"<<endl<<endl;

            // you may need to store the variable names to insert them in symbol table here or later
            $$ = new symbol_info($1->get_name() + "[" + $3->get_name() + "]", "declaration_list");
 		  }
 		  ;


statements : statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statement "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name(),"stmnts");
	   }
	   | statements statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statements statement "<<endl<<endl;
			outlog<<$1->get_name()<<"\n"<<$2->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+"\n"+$2->get_name(),"stmnts");
	   }
	   ;

statement : var_declaration
	  {
	    	outlog<<"At line no: "<<lines<<" statement : var_declaration "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name(),"stmnt");
	  }
	  | func_definition
	  {
	  		outlog<<"At line no: "<<lines<<" statement : func_definition "<<endl<<endl;
            outlog<<$1->get_name()<<endl<<endl;

            $$ = new symbol_info($1->get_name(),"stmnt");

	  }
	  | expression_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : expression_statement "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name(),"stmnt");
	  }
	  | compound_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : compound_statement "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name(),"stmnt");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN scope_entry statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
			outlog<<"for("<<$3->get_name()<<$4->get_name()<<$5->get_name()<<")\n"<<$8->get_name()<<endl<<endl;

			$$ = new symbol_info("for("+$3->get_name()+$4->get_name()+$5->get_name()+")\n"+$8->get_name(),"stmnt");

	  }
	  | IF LPAREN expression RPAREN scope_entry statement %prec LOWER_THAN_ELSE
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"if("<<$3->get_name()<<")\n"<<$6->get_name()<<endl<<endl;

			$$ = new symbol_info("if("+$3->get_name()+")\n"+$6->get_name(),"stmnt");

	  }
	  | IF LPAREN expression RPAREN scope_entry statement ELSE scope_entry statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl<<endl;
			outlog<<"if("<<$3->get_name()<<")\n"<<$5->get_name()<<"\nelse\n"<<$7->get_name()<<endl<<endl;

			$$ = new symbol_info("if("+$3->get_name()+")\n"+$5->get_name()+"\nelse\n"+$7->get_name(),"stmnt");

	  }
	  | WHILE LPAREN expression RPAREN scope_entry statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : WHILE LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"while("<<$3->get_name()<<")\n"<<$6->get_name()<<endl<<endl;

			$$ = new symbol_info("while("+$3->get_name()+")\n"+$6->get_name(),"stmnt");

	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl<<endl;
			outlog<<"printf("<<$3->get_name()<<");"<<endl<<endl;

			$$ = new symbol_info("printf("+$3->get_name()+");","stmnt");

			//Check if the variable is an array by finding '[' in its lexeme
			string variable_name = $3->get_name();
			size_t open_bracket = variable_name.find('[');
			size_t close_bracket = variable_name.find(']');
			if (open_bracket != string::npos && close_bracket != string::npos && close_bracket > open_bracket + 1) {
					string checking_type="Array";
					variable_name = variable_name.substr(0, open_bracket);
					symbol_info* checking = new symbol_info(variable_name, "ID");
					auto result = main_table->lookup(checking,1);
					if (result == nullptr) {
						outlog2 << "At line no: " << lines << " Undeclared array variable : " << variable_name << endl<<endl;
						outlog << "At line no: " << lines << " Undeclared array variable : " << variable_name << endl<<endl;
						errors++;
						}
			}else{
			symbol_info* checking = new symbol_info(variable_name, "ID");
			auto result = main_table->lookup(checking,1);
			if(result == nullptr) {
				// Checking for undeclared variable
				outlog2 << "At line no: " << lines << " Undeclared variable " << variable_name << endl<<endl;
				outlog << "At line no: " << lines << " Undeclared variable " << variable_name << endl<<endl;
				errors++;
				}
			}
	  }
	  | RETURN expression SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : RETURN expression SEMICOLON "<<endl<<endl;
			outlog<<"return "<<$2->get_name()<<";"<<endl<<endl;

			$$ = new symbol_info("return "+$2->get_name()+";","stmnt");
	  }
	  ;


scope_entry :

{
	main_table->enter_scope();
	outlog << "New ScopeTable with ID " << main_table->getCurrentScopeID() << " created" << endl << endl;
}


expression_statement : SEMICOLON
			{
				outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON "<<endl<<endl;
				outlog<<";"<<endl<<endl;

				$$ = new symbol_info(";","expr_stmt");
	        }
			| expression SEMICOLON
			{
				outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON "<<endl<<endl;
				outlog<<$1->get_name()<<";"<<endl<<endl;

				$$ = new symbol_info($1->get_name()+";","expr_stmt");
	        }
			;

variable : ID
      {
	    outlog<<"At line no: "<<lines<<" variable : ID "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;

		$$ = new symbol_info($1->get_name(),"varbl");

	 }
	 | ID LTHIRD expression RTHIRD
	 {
	 	outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD "<<endl<<endl;
		outlog<<$1->get_name()<<"["<<$3->get_name()<<"]"<<endl<<endl;

		$$ = new symbol_info($1->get_name()+"["+$3->get_name()+"]","varbl");

		// Check in the Symbol Table if an array variable with that name exists
		string variable_name = $1->get_name();
		symbol_info* checking = new symbol_info(variable_name, "ID");
		auto result = main_table->lookup(checking,1);
		if( result != nullptr) {
			string variable_type = result->get_symbol_type();
			string value = $3->get_name();
			string value_type = type_conversion(value);
			int array_size = result->get_array_size();


			if(variable_type != "Array"){
					outlog2 << "At line no: " << lines << " variable is not of array type : " << variable_name << endl<<endl;
					outlog << "At line no: " << lines << " variable is not of array type : " << variable_name << endl<<endl;
					errors++;
			}
			else if(value_type == "int") {

				if(stoi(value) >= array_size){
					outlog2 << "At line no: " << lines << " Array index out of bound : " << variable_name << endl<<endl;
					outlog << "At line no: " << lines << " Array index out of bound : " << variable_name << endl<<endl;
					errors++;
				}

			}else if(value_type == "float"){

				outlog2 << "At line no: " << lines << " array index is not of integer type : " << variable_name << endl<<endl;
				outlog << "At line no: " << lines << " array index is not of integer type : " << variable_name << endl<<endl;
				errors++;
			}

			string variable_data_type = result->get_data_type();
			$$->set_data_type(variable_data_type);
		}
		else{
			// Checking for undeclared variable
			outlog2 << "At line no: " << lines << " Undeclared array variable : " << variable_name << endl<<endl;
			outlog << "At line no: " << lines << " Undeclared array variable : " << variable_name << endl<<endl;
			errors++;
		}
	 }
	 ;

expression : logic_expression
	   {
	    	outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name(),"expr");
	   }
	   | variable ASSIGNOP logic_expression
	   {
	    	outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
			outlog<<$1->get_name()<<"="<<$3->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+"="+$3->get_name(),"expr");

			//Check if the variable is an array by finding '[' in its lexeme
			string variable_name = $1->get_name();
			size_t open_bracket = variable_name.find('[');
			size_t close_bracket = variable_name.find(']');
			if (open_bracket != string::npos && close_bracket != string::npos && close_bracket > open_bracket + 1) {
				string checking_type="Array";
				variable_name = variable_name.substr(0, open_bracket);
				symbol_info* checking = new symbol_info(variable_name, "ID");
				auto result = main_table->lookup(checking,1);
				if (result != nullptr) {
					string array_data_type = result->get_data_type();
					//int array_size = result->get_array_size();
					if(array_data_type != $3->get_data_type()   && $3->get_data_type() == "void"){
						outlog2 << "At line no: " << lines << " operation on void type  " << endl<<endl;
						outlog << "At line no: " << lines << " operation on void type  " << endl<<endl;
						errors++;
					}else if(array_data_type == "int" && $3->get_data_type() == "float"){
						outlog2 << "At line no: " << lines << " Warning: Assignment of float value into variable of integer type " << endl<<endl;
						outlog << "At line no: " << lines << " Warning: Assignment of float value into variable of integer type " << endl<<endl;
						errors++;
					}else if(array_data_type != $3->get_data_type()){
						outlog2 << "At line no: " << lines << " Array data type mismatch : " << variable_name << endl<<endl;
						outlog << "At line no: " << lines << " Array data type mismatch : " << variable_name << endl<<endl;
						errors++;
					}
			}
			}else{
			symbol_info* checking = new symbol_info($1->get_name(), "ID");
			auto result = main_table->lookup(checking,1);
			if(result != nullptr) {
				// Checking for undeclared variable
				string checking_type = result->get_data_type();

				if(result->get_symbol_type() == "Array"){
					outlog2 << "At line no: " << lines << " variable is of array type : " << $1->get_name() << endl<<endl;
					outlog << "At line no: " << lines << " variable is of array type : " << $1->get_name() << endl<<endl;
					errors++;
				}

				else if(checking_type == "int" && $3->get_data_type() == "float"){
					outlog2 << "At line no: " << lines << " Warning: Assignment of float value into variable of integer type " << endl<<endl;
					outlog << "At line no: " << lines << " Warning: Assignment of float value into variable of integer type " << endl<<endl;
					errors++;
				}

				else if($3->get_data_type() != checking_type){
					outlog2 << "At line no: " << lines << " Variable type mismatch : " << $1->get_name() <<endl<<endl;
					outlog << "At line no: " << lines << " Variable type mismatch : " << $1->get_name() <<endl<<endl;
					errors++;
				}

			}else{
				// Checking for undeclared variable
				outlog2 << "At line no: " << lines << " Undeclared variable " << $1->get_name() << endl<<endl;
				outlog << "At line no: " << lines << " Undeclared variable " << $1->get_name() << endl<<endl;

				errors++;
			}
	   }
	   }
	   ;

logic_expression : rel_expression
	     {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name(),"lgc_expr");
			$$->set_data_type($1->get_data_type());
	     }
		 | rel_expression LOGICOP rel_expression
		 {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"lgc_expr");
			$$->set_data_type($1->get_data_type());
	     }
		 ;

rel_expression	: simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name(),"rel_expr");
			$$->set_data_type($1->get_data_type());
	    }
		| simple_expression RELOP simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"rel_expr");
			$$->set_data_type($1->get_data_type());
	    }
		;

simple_expression : term
          {
	    	outlog<<"At line no: "<<lines<<" simple_expression : term "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name(),"simp_expr");
			$$->set_data_type($1->get_data_type());
	      }
		  | simple_expression ADDOP term
		  {
	    	outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"simp_expr");
			if($1->get_data_type() == "int" && $3->get_data_type() == "int"){
				$$->set_data_type("int");

			} else if($1->get_data_type() == "float" || $3->get_data_type() == "float"){
				$$->set_data_type("float");

			} else if($1->get_data_type() == "float" || $3->get_data_type() == "int"){
				$$->set_data_type("float");

			} else if($1->get_data_type() == "int" && $3->get_data_type() == "float"){
				$$->set_data_type("float");

			} else if($1->get_data_type() == "void" || $3->get_data_type() == "void"){
			outlog2 << "At line no: " << lines << " operation on void type " << endl<<endl;
			outlog << "At line no: " << lines << " operation on void type " << endl<<endl;
			errors++;

			} else{
			outlog2 << "At line no: " << lines << " data type mismatch on arithmetic operation " << endl<<endl;
			outlog << "At line no: " << lines << " data type mismatch on arithmetic operation " << endl<<endl;
			errors++;
			}
	      }
		  ;

term :	unary_expression //term can be void because of un_expr->factor
     {
	    	outlog<<"At line no: "<<lines<<" term : unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name(),"term");
			$$->set_data_type($1->get_data_type());

	 }
     |  term MULOP unary_expression
     {
	    	outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"term");
			if($2->get_name()== "%" && $3->get_name()=="0"){
				outlog2 << "At line no: " << lines << " Modulus by 0 " << endl<<endl;
				outlog << "At line no: " << lines << " Modulus by 0 " << endl<<endl;
				errors++;
				$$->set_data_type("int");
			} else if($2->get_name()== "%" && $3->get_data_type()!="int"){
				outlog2 << "At line no: " << lines << " Modulus operator on non integer type " << endl<<endl;
				outlog << "At line no: " << lines << " Modulus operator on non integer type " << endl<<endl;
				errors++;
				$$->set_data_type("int");

			} else if($2->get_name()== "%" && $1->get_data_type()!="int"){
				outlog2 << "At line no: " << lines << " Modulus operator on non integer type " << endl<<endl;
				outlog << "At line no: " << lines << " Modulus operator on non integer type " << endl<<endl;
				errors++;
				$$->set_data_type("int");
			} else if($2->get_name()== "/" && $1->get_data_type()!="0"){
				outlog2 << "At line no: " << lines << " Zero division error " << endl<<endl;
				outlog << "At line no: " << lines << " Zero division error " << endl<<endl;
				errors++;
				$$->set_data_type("int");
			} else if($1->get_data_type() == "int" && $3->get_data_type() == "int"){
				$$->set_data_type("int");
			} else if($1->get_data_type() == "float" || $3->get_data_type() == "float"){
				$$->set_data_type("float");
			} else if($1->get_data_type() == "float" || $3->get_data_type() == "int"){
				$$->set_data_type("float");
			} else if($1->get_data_type() == "int" && $3->get_data_type() == "float"){
				$$->set_data_type("float");
			} else if($1->get_data_type() == "void" || $3->get_data_type() == "void"){
			outlog2 << "At line no: " << lines << " operation on void type " << endl<<endl;
			outlog << "At line no: " << lines << " operation on void type " << endl<<endl;
			errors++;

			if($1->get_data_type() == "void" && $3->get_data_type() != "void"){
				$$->set_data_type($3->get_data_type());
			}else if($3->get_data_type() == "void" && $1->get_data_type() != "void"){
				$$->set_data_type($1->get_data_type());
			}else{
				$$->set_data_type("void");
			}
			}else{
			outlog2 << "At line no: " << lines << " data type mismatch on arithmetic operation " << endl<<endl;
			outlog << "At line no: " << lines << " data type mismatch on arithmetic operation " << endl<<endl;
			errors++;
			}
	 }
     ;

unary_expression : ADDOP unary_expression  // un_expr can be void because of factor
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name()+$2->get_name(),"un_expr");
	     }
		 | NOT unary_expression
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression "<<endl<<endl;
			outlog<<"!"<<$2->get_name()<<endl<<endl;

			$$ = new symbol_info("!"+$2->get_name(),"un_expr");
	     }
		 | factor
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : factor "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			$$ = new symbol_info($1->get_name(),"un_expr");
			$$->set_data_type($1->get_data_type());
	     }
		 ;

factor	: variable
    {
	    outlog<<"At line no: "<<lines<<" factor : variable "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;

		$$ = new symbol_info($1->get_name(),"fctr");
	}
	| ID LPAREN argument_list RPAREN
	{
		outlog << "At line no: " << lines << " factor : ID LPAREN argument_list RPAREN " << endl << endl;
		outlog << $1->get_name() << "(" << $3->get_name() << ")" << endl << endl;

		//$$ = new symbol_info($1->get_name()+"("+$3->get_name()+")","fctr");

		vector<string> given = split($3->get_name(), ',');
		auto result = main_table->lookup($1, 1);

		if (result != nullptr) {
			auto param_types = result->get_param_types();
			auto param_names = result->get_param_names();

			// Checking for inconsistencies in number of arguments in function call
			if (param_types.size() != given.size()) {
				outlog2 << "At line no: " << lines
						<< " Inconsistencies in number of arguments in function call: " << $1->get_name() << endl << endl;
				outlog << "At line no: " << lines
					<< " Inconsistencies in number of arguments in function call: " << $1->get_name() << endl << endl;
				errors++;
			}

			$$ = new symbol_info($1->get_name() + "(" + $3->get_name() + ")", "fctr");
			string function_return_type = result->get_data_type();
			$$->set_data_type(function_return_type);

			// checking if the argument types are correct or not
			for (size_t i = 0; i < param_types.size(); ++i) {
				if (i >= given.size()) {
					break;
				}

				string target = param_types[i];
				auto current = type_conversion(given[i]);

				if (current == "ID") {
					size_t open_bracket = given[i].find('[');
					size_t close_bracket = given[i].find(']');

					if (open_bracket != string::npos && close_bracket != string::npos && close_bracket > open_bracket + 1) {
						string variable_name = given[i].substr(0, open_bracket);
						symbol_info* checking = new symbol_info(variable_name, "ID");
						auto result = main_table->lookup(checking, 1);

						if (result == nullptr) {
							outlog2 << "At line no: " << lines << " Undeclared variable " << variable_name << endl << endl;
							outlog << "At line no: " << lines << " Undeclared variable " << variable_name << endl << endl;
							errors++;
						}
					} else {
						// If the argument is a variable type
						symbol_info* checking = new symbol_info(given[i], "ID");
						auto result = main_table->lookup(checking, 1);

						if (result != nullptr) {
							current = result->get_symbol_type();

							if (current == "Array") {
								outlog2 << "At line no: " << lines << " variable is of array type : " << given[i] << endl << endl;
								outlog << "At line no: " << lines << " variable is of array type : " << given[i] << endl << endl;
								errors++;
							}
							else if (current == "Function Definition") {
								outlog2 << "At line no: " << lines << " variable is of function type : " << given[i] << endl << endl;
								outlog << "At line no: " << lines << " variable is of function type : " << given[i] << endl << endl;
								errors++;
							}
							else {
								current = result->get_data_type();
								if (target != current) {
									outlog2 << "At line no: " << lines
											<< " argument " << i + 1
											<< " type mismatch in function call: " << $1->get_name() << endl << endl;
									outlog << "At line no: " << lines
										<< " argument " << i + 1
										<< " type mismatch in function call: " << $1->get_name() << endl << endl;
									errors++;
								}
							}
						} else {
							// Checking for undeclared variable passed in function call argument
							outlog2 << "At line no: " << lines << " Undeclared variable " << given[i] << endl << endl;
							outlog << "At line no: " << lines << " Undeclared variable " << given[i] << endl << endl;
							errors++;
						}
					}
				} else {
					if (target != current) {
						outlog2 << "At line no: " << lines
								<< " argument " << i + 1
								<< " type mismatch in function call: " << $1->get_name() << endl << endl;
						outlog << "At line no: " << lines
							<< " argument " << i + 1
							<< " type mismatch in function call: " << $1->get_name() << endl << endl;
						errors++;
					}
				}
			}
		}
		else {
			// Checking for undeclared function
			outlog2 << "At line no: " << lines << " Undeclared function: " << $1->get_name() << endl << endl;
			outlog << "At line no: " << lines << " Undeclared function: " << $1->get_name() << endl << endl;
			errors++;

			$$ = new symbol_info($1->get_name() + "(" + $3->get_name() + ")", "fctr");
			$$->set_data_type("int");
		}
	}
	| LPAREN expression RPAREN
	{
	   	outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN "<<endl<<endl;
		outlog<<"("<<$2->get_name()<<")"<<endl<<endl;

		$$ = new symbol_info("("+$2->get_name()+")","fctr");
	}
	| CONST_INT
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_INT "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;

		$$ = new symbol_info($1->get_name(),"fctr");
		$$->set_data_type("int");
	}
	| CONST_FLOAT
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;

		$$ = new symbol_info($1->get_name(),"fctr");
		$$->set_data_type("float");
	}
	| variable INCOP
	{
	    outlog<<"At line no: "<<lines<<" factor : variable INCOP "<<endl<<endl;
		outlog<<$1->get_name()<<"++"<<endl<<endl;

		$$ = new symbol_info($1->get_name()+"++","fctr");
	}
	| variable DECOP
	{
	    outlog<<"At line no: "<<lines<<" factor : variable DECOP "<<endl<<endl;
		outlog<<$1->get_name()<<"--"<<endl<<endl;

		$$ = new symbol_info($1->get_name()+"--","fctr");
	}
	;

argument_list : arguments
			  {
					outlog<<"At line no: "<<lines<<" argument_list : arguments "<<endl<<endl;
					outlog<<$1->get_name()<<endl<<endl;

					$$ = new symbol_info($1->get_name(),"arg_list");
			  }
			  |
			  {
					outlog<<"At line no: "<<lines<<" argument_list :  "<<endl<<endl;
					outlog<<""<<endl<<endl;

					$$ = new symbol_info("","arg_list");
			  }
			  ;

arguments : arguments COMMA logic_expression
		  {
				outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression "<<endl<<endl;
				outlog<<$1->get_name()<<","<<$3->get_name()<<endl<<endl;

				$$ = new symbol_info($1->get_name()+","+$3->get_name(),"arg");
		  }
	      | logic_expression
	      {
				outlog<<"At line no: "<<lines<<" arguments : logic_expression "<<endl<<endl;
				outlog<<$1->get_name()<<endl<<endl;

				$$ = new symbol_info($1->get_name(),"arg");
		  }
	      ;


%%

int main(int argc, char *argv[])
{
	if(argc != 2)
	{
		cout<<"Please input file name"<<endl;
		return 0;
	}
	yyin = fopen(argv[1], "r");
	outlog.open("24241257_log.txt", ios::trunc);
	outlog2.open("24241257_error.txt", ios::trunc);

	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}
	// Enter the global or the first scope here
	main_table = new symbol_table(107);
    //main_table->enter_scope();
	outlog << "New ScopeTable with ID " << main_table->getCurrentScopeID() << " created" << endl << endl;
	yyparse();

	outlog<<endl<<"Total lines: "<<lines<<endl;
	outlog<<endl<<"Total errors: "<<errors<<endl;
	outlog2<<endl<<"Total errors: "<<errors<<endl;

	outlog.close();
	outlog2.close();

	fclose(yyin);

	return 0;
}