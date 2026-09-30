// js/supabase.js
// Initialize Supabase Client

// IMPORTANT: Replace these with your actual Supabase project credentials
// You can find these in your Supabase Dashboard -> Project Settings -> API
const SUPABASE_URL = "https://nvlzwvnnennmihdyauuo.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im52bHp3dm5uZW5ubWloZHlhdXVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA3NzM5MTEsImV4cCI6MjEwNjM0OTkxMX0.lRYn8CojN3tS21Ucyak43aMSsmsNchG6MQHLs8QvNVo";

// Create a single supabase client for interacting with your database
const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Utility function to check current session
async function getCurrentUser() {
    const { data: { session }, error } = await supabase.auth.getSession();
    if (error || !session) return null;
    
    // Fetch profile
    const { data: profile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', session.user.id)
        .single();
        
    return profile ? { ...session.user, profile } : session.user;
}

// Utility function to logout
async function logout() {
    await supabase.auth.signOut();
    window.location.href = '/index.html';
}
