Requirements
============
* virtualbox >= 5.2.2
* vagrant >= 2.0.1
* ansible >= 2.4.2.0
* cfssl >= 1.2.0



`cfssl gencert -initca ca-csr.json | cfssljson -bare ca` 
* generates `ca.pem` `ca-key.pem` `ca.csr`

