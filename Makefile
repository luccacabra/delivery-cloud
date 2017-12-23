SHELL := /bin/bash

bootstrap-certs:
	cfssl gencert -initca csr/ca-csr.json | cfssljson -bare csr/ca/ca \
	&& cfssl gencert \
		 -ca=csr/ca/ca.pem \
		 -ca-key=csr/ca/ca-key.pem \
		 -config=csr/ca-config.json \
		 -profile=kubernetes \
		 csr/admin-csr.json | cfssljson -bare csr/ca/admin \
	&& cfssl gencert \
		 -ca=csr/ca/ca.pem \
		 -ca-key=csr/ca/ca-key.pem \
		 -config=csr/ca-config.json \
		 -profile=kubernetes \
		 csr/kube-proxy-csr.json | cfssljson -bare csr/ca/kube-proxy