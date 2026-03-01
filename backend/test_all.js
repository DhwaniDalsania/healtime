const mongoose = require('mongoose');
const User = require('./models/User');
const Message = require('./models/Message');

async function testContacts() {
    await mongoose.connect('mongodb://localhost:27017/healtime');

    const anyMessage = await Message.findOne();
    if (!anyMessage) {
        console.log("NO MESSAGES IN DATABASE AT ALL!");
        return await mongoose.disconnect();
    }

    console.log("Found a message in DB:", anyMessage);

    const userId = anyMessage.senderId.toString();
    console.log("Testing with User ID:", userId);

    const messages = await Message.find({
        $or: [{ senderId: userId }, { receiverId: userId }]
    }).sort({ createdAt: -1 });

    console.log("Messages for this user:", messages.length);

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
    console.log("Mapped Contact IDs:", contactIds);

    const users = await User.find({ _id: { $in: contactIds } }, 'name role imageUrl specialty');
    console.log("Found Users:", users.map(u => ({ id: u._id, name: u.name })));

    const result = users.map(user => {
        const contactInfo = contactsMap.get(user._id.toString());
        return {
            id: user._id,
            name: user.name,
            lastMessage: contactInfo ? contactInfo.lastMessage : 'Not Found',
        };
    });

    console.log("Final Result length:", result.length);
    console.log("Final Result:", result);

    await mongoose.disconnect();
}

testContacts().catch(console.error);
