install-server:
	cd server && make install

install-custom-kernels:
	if [ "$$BUILD_EXTENSIONS" = "True" ]; then cd server/custom_kernels && python setup.py install; else echo "Custom kernels are disabled, you need to set the BUILD_EXTENSIONS environment variable to 'True' in order to build them. (Please read the docs, kernels might not work on all hardware)"; fi

install-integration-tests:
	cd integration-tests && pip install -r requirements.txt
	cd clients/python && pip install .

install-router:
	cd router && cargo install --path .

install-launcher:
	cd launcher && cargo install --path .

install-benchmark:
	cd benchmark && cargo install --path .

install: install-server install-router install-launcher install-custom-kernels

server-dev:
	cd server && make run-dev

router-dev:
	cd router && cargo run -- --port 8080

rust-tests: install-router install-launcher
	cargo test

integration-tests: install-integration-tests
	pytest -s -vv -m "not private" integration-tests

update-integration-tests: install-integration-tests
	pytest -s -vv --snapshot-update integration-tests

python-server-tests:
	HF_HUB_ENABLE_HF_TRANSFER=1 pytest -s -vv -m "not private" server/tests

python-client-tests:
	pytest clients/python/tests

python-tests: python-server-tests python-client-tests

run-rhino:
	text-generation-launcher --model-id adypd/rhino-v0 --port 6006 --max-total-tokens 4096 --max-input-length 3584

run-llama2-13b-chat-hf:
	text-generation-launcher --model-id meta-llama/Llama-2-13b-chat-hf --port 6006 

run-llama2-7b-hf:
	text-generation-launcher --model-id meta-llama/Llama-2-7b-chat-hf --port 6006 

run-falcon-7b-instruct-quantize:
	text-generation-launcher --model-id tiiuae/falcon-7b-instruct --quantize bitsandbytes --port 8080

clean:
	rm -rf target aml
