require_relative 'waid_exception'

=begin
ErrorPosition = Struct.new(
    :file_path,
    :line_number
    :column_number
    :source_offset
    :full_line
)
=end

def number_of_digits(num)
    Math.log10(num + 1).ceil
end

CompilationError = Struct.new(:error_description, :full_line, :source_position) do
    def to_s
        # Ya que implementaré estos mensajes de error en el futuro, me quedo satisfecho con unos más simples.
        # Modelos de errores
        # Ni siquiera sé si son errores reales, pero sirven para mostrar la estructura:
        # 
        # main.vt
        #     Error: Unknown identifier 'retrn'
        #     23| square: func(x: int): int => retrn !math::pow(x, 2);
        #                                      ^~~~~
        #     Error: Expected ')' before ':'
        #     97| chType: generic<OR, NW> func(or: OR[]: NW[] =>
        #                                              ^
        # core.vt
        #     Error: 'reset_token()' takes exactly 1 argument (2 given)
        #     15|     token_arr@[i] => !->reset_token(token_arr@[i], x_coord - 2);
        #                                                            ^~~~~~~~~~~
        error_string = "Error: #{error_description}\n\t#{source_position.line}| #{full_line}\n\t"
        error_string += " " * (source_position.column + number_of_digits(source_position.line) + 2) + "^"
    end
end

class ErrorCollector
    def initialize
        @errors = Array.new
    end

    def add_error(comp_error)
        @errors.push(comp_error)
    end

    def has_errors
        not @errors.empty?
    end

    def show_errors
        @errors.each do |err|
            puts "\t#{err.to_s}"
        end
        raise WaidError.new("#{@errors.size} #{@errors.size > 1? 'errors' : 'error'}", "Waid")
    end
end