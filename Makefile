.PHONY: run build test format clean

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
