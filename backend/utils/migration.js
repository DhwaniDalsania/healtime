const User = require('../models/User');
const Message = require('../models/Message');
const bcrypt = require('bcrypt');
const { encrypt } = require('./encryption');

async function migrateDatabase() {
    console.log('--- STARTING DATABASE MIGRATION ---');

    try {
        // 1. Password Migration
        const users = await User.find({});
        let migratedUsersCount = 0;
        
        for (const user of users) {
            // Check if password is already a bcrypt hash
            // Bcrypt hash is always 60 characters long and begins with '$2'
            const isBcrypt = user.password && user.password.length === 60 && user.password.startsWith('$2');
            
            if (!isBcrypt && user.password) {
                console.log(`Migrating/Hashing password for user: ${user.email}`);
                const salt = await bcrypt.genSalt(10);
                user.password = await bcrypt.hash(user.password, salt);
                await user.save();
                migratedUsersCount++;
            }
        }
        console.log(`Successfully migrated ${migratedUsersCount} user password(s).`);

        // 2. Chat Messages Migration
        // Find messages where 'ciphertext' field is missing or empty,
        // and we fetch the raw document using lean() to access the 'content' field
        const legacyMessages = await Message.find({
            $or: [
                { ciphertext: { $exists: false } },
                { ciphertext: null }
            ]
        }).lean(); // .lean() is essential to read the 'content' field since it's not defined in the Schema anymore
        
        let migratedMessagesCount = 0;
        
        for (const rawMsg of legacyMessages) {
            // Note: rawMsg is a plain JS object, so it will contain 'content' if it existed in MongoDB
            if (rawMsg.content) {
                console.log(`Encrypting legacy message ID: ${rawMsg._id}`);
                const encryptedPayload = encrypt(rawMsg.content);
                
                await Message.updateOne(
                    { _id: rawMsg._id },
                    {
                        $set: {
                            ciphertext: encryptedPayload.ciphertext,
                            iv: encryptedPayload.iv,
                            tag: encryptedPayload.tag
                        },
                        $unset: {
                            content: "" // Unset the legacy plain-text field from the database
                        }
                    }
                );
                migratedMessagesCount++;
            }
        }
        console.log(`Successfully encrypted and migrated ${migratedMessagesCount} message(s).`);
        console.log('--- DATABASE MIGRATION COMPLETED ---');
    } catch (error) {
        console.error('Error occurred during database migration:', error);
        throw error;
    }
}

module.exports = {
    migrateDatabase
};
