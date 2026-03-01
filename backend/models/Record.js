const mongoose = require('mongoose');

const recordSchema = new mongoose.Schema({
    patientId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    doctorId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    doctorName: {
        type: String,
        required: true
    },
    date: {
        type: String, // format YYYY-MM-DD
        required: true
    },
    diagnosis: {
        type: String,
        required: true
    },
    prescription: {
        type: String,
        default: ''
    },
    attachments: [{
        type: String
    }]
}, {
    timestamps: true
});

module.exports = mongoose.model('Record', recordSchema);
