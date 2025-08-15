#include "symbol_info.h"

class scope_table
{
private:
    int bucket_count;
    int unique_id;
    scope_table *parent_scope = NULL;
    vector<list<symbol_info *>> table;

    int hash_function(string name)
    {
        unsigned long long hash = 5381;
        for (char c : name)
        {
            hash = ((hash << 5) + hash) + c;
        }

        return hash % bucket_count;
    }

public:
    scope_table() : bucket_count(107), unique_id(0), parent_scope(nullptr), table(vector<list<symbol_info*>>(107)) {

    }

    scope_table(int bucket_count, int unique_id, scope_table *parent_scope){
        this->bucket_count = bucket_count;
        this->unique_id = unique_id;
        this->parent_scope = parent_scope;
        this->table = vector<list<symbol_info*>>(bucket_count);
    }

    scope_table* get_parent_scope(){
        return parent_scope;
    }

    int get_unique_id(){
        return unique_id;
    }

    symbol_info* lookup_in_scope(symbol_info* symbol){
        string symbol_name = symbol->get_name();
        int idx = hash_function(symbol_name);

        for (auto& values : table[idx]) {
            if (values->get_name() == symbol->get_name()) {
                return values;
            }
        }
        return nullptr;
    }

    bool insert_in_scope(symbol_info* symbol) {

        auto found = lookup_in_scope(symbol);
        if (!found) {
            string symbol_name = symbol->get_name();
            int idx = hash_function(symbol_name);
            table[idx].push_back(symbol);
            return true;
        }
        return false;
    }

    bool delete_from_scope(symbol_info* symbol){
        string symbol_name = symbol->get_name();
        int index = hash_function(symbol_name);

        auto& instances = table[index];
        for (auto values = instances.begin(); values != instances.end(); ++values) {
            if ((*values)->get_name() == symbol->get_name()) {
                delete *values;  // Freeing the memory
                instances.erase(values);  // We need to pass the address in this erase function and thats why we are using the iterator based looping
                return true;
            }
        }
        return false;
    }

    void print_scope_table(ofstream& outlog);

    ~scope_table(){

        for (auto &bucket : table) {
            for (auto symbol : bucket) {
                delete symbol;
                symbol = nullptr;
            }
        }
    }

    // you can add more methods if you need
};

// complete the methods of scope_table class
void scope_table::print_scope_table(ofstream& outlog)
{
    outlog << "ScopeTable # "+ to_string(unique_id) << endl;

    //iterate through the current scope table and print the symbols and all relevant information
    // outlog << "ScopeTable # " << unique_id <<endl;
    for (int i = 0; i < bucket_count; ++i) {
        if (!table[i].empty()) {
            outlog << i << "--> " << endl;
            for (auto symbol : table[i]) {
                outlog << "< " << symbol->get_name() << " : " << symbol->get_type() << " > " << endl;
                outlog  << symbol->get_symbol_type()  << endl;


                if(symbol->get_symbol_type()=="Function Definition"){
                    outlog << "Return Type : " << symbol->get_data_type() << endl;

                        auto types = symbol->get_param_types();
                        auto names = symbol->get_param_names();

                        outlog << "Number of Parameters: " << types.size() << endl;

                        outlog << "Parameter Details: ";
                        for (size_t i = 0; i < types.size(); ++i) {
                            outlog << types[i] << " " << names[i];
                            if (i != types.size() - 1) {
                                outlog << ", ";
                            }
                        }
                        outlog << endl;
                    }else{
                        int array_size = symbol->get_array_size() ;
                        if(array_size!=0){
                            outlog << "Type : " << symbol->get_data_type() << endl;
                            outlog << "Size : " << array_size << endl;

                        }else{
                        outlog << "Type : " << symbol->get_data_type() << endl;
                        }
                    }
                outlog << endl ;
            }
        }
    }
}