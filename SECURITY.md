# Security — Chatly

## Encryption

Chatly encrypts messages **client-side** using AES-256-GCM before they leave the device.

- **Algorithm**: AES-256-GCM (authenticated encryption)
- **Key size**: 256 bits
- **Nonce**: Random 96-bit per message (unique ciphertexts for identical plaintexts)
- **Key derivation**: PBKDF2 with 100,000 iterations (where applicable)
- **Authentication**: GCM provides built-in integrity verification

Messages stored in Firestore with `isEncrypted: true` contain only ciphertext. Firebase administrators cannot read message content.

## Current Limitations

- **Key exchange**: Session keys are currently stored alongside encrypted messages in Firestore. A proper Signal Protocol-style key exchange (X3DH + Double Ratchet) is on the roadmap.
- **Perfect Forward Secrecy**: Not yet implemented. Current session key rotation is manual.
- **Metadata**: Chat participants and timestamps are visible in Firestore. Only message content is encrypted.

## Reporting Vulnerabilities

If you discover a security vulnerability, please **do not** open a public issue.

Email: saffanakbar942@gmail.com

## Best Practices for Deployment

1. **Rotate Firebase credentials** if they've ever been exposed
2. **Set Firestore security rules** to restrict read/write access
3. **Never commit `.env`** — it's in `.gitignore`
4. **Use strong passwords** for Firebase Auth
5. **Enable Firebase App Check** for additional protection
