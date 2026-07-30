require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');
const Message = require('./models/Message');

async function runSecurityTests() {
    console.log('=== STARTING SECURITY TESTS ===');
    
    // Connect to database
    await mongoose.connect(process.env.MONGODB_URI);
    
    // 1. Password Hashing Verification
    console.log('\n1. Verifying password hashing before storage...');
    const testEmail = `test_security_${Date.now()}@example.com`;
    const plainPassword = 'SuperSecurePassword123!';
    
    const testUser = new User({
        name: 'Security Test User',
        email: testEmail,
        password: plainPassword,
        role: 'patient'
    });
    
    // Save user to database
    await testUser.save();
    
    // Fetch directly from database to verify raw fields
    const savedUserInDb = await User.findOne({ email: testEmail });
    
    console.log('Saved user password field in DB:', savedUserInDb.password);
    
    if (savedUserInDb.password === plainPassword) {
        throw new Error('FAIL: Password stored in plain text!');
    }
    
    // Verify it starts with standard bcrypt prefix ($2b$ or $2a$)
    if (!savedUserInDb.password.startsWith('$2')) {
        throw new Error('FAIL: Password is not a valid bcrypt hash!');
    }
    console.log('SUCCESS: Password is securely hashed using bcrypt.');
    
    // 2. Login verification using hashed password
    console.log('\n2. Verifying login works with hashed password...');
    const isPasswordCorrect = await savedUserInDb.comparePassword(plainPassword);
    if (!isPasswordCorrect) {
        throw new Error('FAIL: Cannot verify correct password using comparePassword!');
    }
    
    const isPasswordIncorrect = await savedUserInDb.comparePassword('WrongPassword123!');
    if (isPasswordIncorrect) {
        throw new Error('FAIL: Verification succeeded for incorrect password!');
    }
    console.log('SUCCESS: Password verification works correctly.');
    
    // 3. Message encryption verification in DB
    console.log('\n3. Verifying chat messages are encrypted in the database...');
    const senderId = new mongoose.Types.ObjectId();
    const receiverId = new mongoose.Types.ObjectId();
    const messageContent = 'This is a top secret medical message!';
    
    const testMsg = new Message({
        senderId,
        receiverId,
        content: messageContent
    });
    
    await testMsg.save();
    
    // Fetch raw message directly from MongoDB bypassing Mongoose virtual getters
    const rawMsgInDb = await Message.findOne({ _id: testMsg._id }).lean();
    
    console.log('Raw message object in DB:', rawMsgInDb);
    
    if (rawMsgInDb.content !== undefined) {
        throw new Error('FAIL: Plain text message content is still stored in DB!');
    }
    
    if (!rawMsgInDb.ciphertext || !rawMsgInDb.iv || !rawMsgInDb.tag) {
        throw new Error('FAIL: Missing ciphertext, iv, or tag in stored document!');
    }
    console.log('SUCCESS: Message content is encrypted in the database (stored only ciphertext, iv, tag).');
    
    // 4. Decrypted message matches original content
    console.log('\n4. Verifying decrypted message matches original content...');
    // Fetch via standard Mongoose (which triggers virtual getter)
    const fetchedMsg = await Message.findById(testMsg._id);
    console.log('Decrypted message content:', fetchedMsg.content);
    
    if (fetchedMsg.content !== messageContent) {
        throw new Error(`FAIL: Decrypted content '${fetchedMsg.content}' does not match original '${messageContent}'!`);
    }
    console.log('SUCCESS: Decrypted content matches original content.');
    
    // Clean up test data
    console.log('\nCleaning up test data...');
    await User.deleteOne({ email: testEmail });
    await Message.deleteOne({ _id: testMsg._id });
    
    console.log('\n--- ALL SECURITY TESTS PASSED SUCCESSFULLY! ---');
    await mongoose.disconnect();
}

runSecurityTests().catch(async (error) => {
    console.error('\nTEST RUN FAILED:', error);
    try {
        await mongoose.disconnect();
    } catch (_) {}
    process.exit(1);
});
