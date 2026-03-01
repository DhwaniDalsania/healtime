const mongoose = require('mongoose');
const User = require('./models/User');
const Message = require('./models/Message');

async function testContacts() {
    await mongoose.connect('mongodb://localhost:27017/healtime');

    // get a patient
    const patient = await User.findOne({ role: 'patient' });
    console.log("Testing contacts for patient:", patient.name, patient._id);

    const userId = patient._id.toString();

    // Find all messages where the user is either sender or receiver
    const messages = await Message.find({
        $or: [{ senderId: userId }, { receiverId: userId }]
    }).sort({ createdAt: -1 });

    console.log("Found messages count:", messages.length);

    // Extract unique contact IDs and the latest message
    const contactsMap = new Map();

    for (const msg of messages) {
        const contactId = msg.senderId.toString() === userId ? msg.receiverId.toString() : msg.senderId.toString();

        if (!contactsMap.has(contactId)) {
            contactsMap.set(contactId, {
                contactId: contactId,
                lastMessage: msg.content,
                timestamp: msg.createdAt
            });
        }
    }

    const contactIds = Array.from(contactsMap.keys());
    console.log("Contact IDs:", contactIds);

    // Fetch user details for those contacts
    const users = await User.find({ _id: { $in: contactIds } }, 'name role imageUrl specialty');

    const result = users.map(user => {
        const contactInfo = contactsMap.get(user._id.toString());
        return {
            id: user._id,
            name: user.name,
            role: user.role,
            imageUrl: user.imageUrl,
            specialty: user.specialty,
            lastMessage: contactInfo.lastMessage,
            timestamp: contactInfo.timestamp
        };
    });

    result.sort((a, b) => b.timestamp - a.timestamp);
    console.log("Result:", JSON.stringify(result, null, 2));

    await mongoose.disconnect();
}

testContacts().catch(console.error);
