const crypto = require('crypto');

const ENCRYPTION_KEY = process.env.CHAT_ENCRYPTION_KEY;

function getKey() {
    if (!ENCRYPTION_KEY) {
        throw new Error('CHAT_ENCRYPTION_KEY environment variable is not set');
    }
    // If it's a 64-character hex string, parse it as a 32-byte buffer
    if (ENCRYPTION_KEY.length === 64 && /^[0-9a-fA-F]+$/.test(ENCRYPTION_KEY)) {
        return Buffer.from(ENCRYPTION_KEY, 'hex');
    }
    // Fallback: UTF-8 encoding padded/truncated to 32 bytes
    return Buffer.alloc(32, ENCRYPTION_KEY, 'utf-8');
}

/**
 * Encrypt plain text using AES-256-GCM
 * @param {string} text Plain text to encrypt
 * @returns {{ciphertext: string, iv: string, tag: string}} Encrypted payload
 */
function encrypt(text) {
    if (text === null || text === undefined) {
        return text;
    }
    
    const key = getKey();
    // AES-GCM standard IV length is 12 bytes (96 bits)
    const iv = crypto.randomBytes(12);
    const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
    
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const tag = cipher.getAuthTag().toString('hex');
    
    return {
        ciphertext: encrypted,
        iv: iv.toString('hex'),
        tag: tag
    };
}

/**
 * Decrypt cipher text using AES-256-GCM
 * @param {string} ciphertext Hex encoded encrypted text
 * @param {string} ivHex Hex encoded IV
 * @param {string} tagHex Hex encoded auth tag
 * @returns {string} Decrypted plain text
 */
function decrypt(ciphertext, ivHex, tagHex) {
    if (!ciphertext || !ivHex || !tagHex) {
        throw new Error('Missing encryption parameters (ciphertext, iv, tag)');
    }
    
    const key = getKey();
    const iv = Buffer.from(ivHex, 'hex');
    const tag = Buffer.from(tagHex, 'hex');
    const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
    
    decipher.setAuthTag(tag);
    
    let decrypted = decipher.update(ciphertext, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
}

module.exports = {
    encrypt,
    decrypt
};
