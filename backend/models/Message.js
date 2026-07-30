const mongoose = require('mongoose');
const { encrypt, decrypt } = require('../utils/encryption');

const messageSchema = new mongoose.Schema({
    senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    receiverId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    ciphertext: { type: String },
    iv: { type: String },
    tag: { type: String }
}, { 
    timestamps: true,
    toObject: { virtuals: true },
    toJSON: { virtuals: true }
});

// Virtual getter and setter for content
messageSchema.virtual('content')
    .get(function() {
        if (this._decryptedContent !== undefined) {
            return this._decryptedContent;
        }
        if (this.ciphertext && this.iv && this.tag) {
            try {
                this._decryptedContent = decrypt(this.ciphertext, this.iv, this.tag);
                return this._decryptedContent;
            } catch (err) {
                console.error(`Decryption failed for message ${this._id}:`, err);
                return '[Decryption Failed]';
            }
        }
        return undefined;
    })
    .set(function(value) {
        this._decryptedContent = value;
        if (value) {
            try {
                const encrypted = encrypt(value);
                this.ciphertext = encrypted.ciphertext;
                this.iv = encrypted.iv;
                this.tag = encrypted.tag;
            } catch (err) {
                throw err;
            }
        }
    });

// Pre-save validation
messageSchema.pre('save', function(next) {
    if (!this.ciphertext || !this.iv || !this.tag) {
        return next(new Error('Message content is required and must be successfully encrypted.'));
    }
    next();
});

// Configure JSON and Object transforms to remove the encrypted fields from API responses
const transform = (doc, ret) => {
    delete ret.ciphertext;
    delete ret.iv;
    delete ret.tag;
    return ret;
};

messageSchema.set('toJSON', {
    virtuals: true,
    transform: transform
});

messageSchema.set('toObject', {
    virtuals: true,
    transform: transform
});

module.exports = mongoose.model('Message', messageSchema);
