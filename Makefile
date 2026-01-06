.PHONY: run build test format clean gen-words build-web serve-web kill-server

PORT := 8080

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

# Build for JavaScript target (Web)
build-web:
	gleam build --target javascript

# Kill any process using the server port
kill-server:
	@-lsof -ti :$(PORT) | xargs kill -9 2>/dev/null || true

# Start local development server for Web version
serve-web: kill-server build-web
	@echo "Starting server at http://localhost:$(PORT)"
	python3 -m http.server $(PORT)
