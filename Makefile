.PHONY: run build test format clean gen-words

run:
	gleam run

build:
	gleam build

test:
	gleam test

format:
	gleam format

clean:
	rm -rf build

# Generate src/wordlish/words_data.gleam from priv/*.txt
gen-words:
	gleam run -m codegen
