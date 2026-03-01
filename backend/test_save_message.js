const mongoose = require('mongoose');
const User = require('./models/User');
const Message = require('./models/Message');

async function testContacts() {
    await mongoose.connect('mongodb://localhost:27017/healtime');

    // get a patient
    const patient = await User.findOne({ role: 'patient' });
    const doc = await User.findOne({ role: 'doctor' });

    console.log("Patient:", patient._id);
    console.log("Doctor:", doc._id);

    try {
        const message = new Message({ senderId: patient._id.toString(), receiverId: doc._id.toString(), content: 'test message from script' });
        await message.save();
        console.log("Saved successfully!");
    } catch (err) {
        console.error("Save error:", err);
    }
    await mongoose.disconnect();
}

testContacts().catch(console.error);
