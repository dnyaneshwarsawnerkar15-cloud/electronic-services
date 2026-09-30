-- supabase/schema.sql

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (Customers, Providers, Admins)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    mobile TEXT,
    address TEXT,
    city TEXT,
    pincode TEXT,
    profile_image TEXT,
    role TEXT CHECK (role IN ('customer', 'provider', 'admin')) DEFAULT 'customer',
    status TEXT CHECK (status IN ('pending', 'approved', 'rejected', 'suspended')) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Service Providers
CREATE TABLE service_providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    owner_name TEXT NOT NULL,
    shop_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    mobile TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    pincode TEXT NOT NULL,
    latitude NUMERIC,
    longitude NUMERIC,
    experience INTEGER,
    description TEXT,
    image_url TEXT,
    registration_number TEXT,
    working_hours TEXT,
    status TEXT CHECK (status IN ('pending', 'approved', 'rejected', 'suspended')) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Technicians
CREATE TABLE technicians (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID REFERENCES service_providers(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    mobile TEXT NOT NULL,
    photo_url TEXT,
    experience INTEGER,
    skills TEXT,
    appliance_expertise TEXT,
    area TEXT,
    availability TEXT DEFAULT 'available',
    status TEXT CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Appliance Categories
CREATE TABLE appliance_categories (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    icon TEXT,
    description TEXT,
    status TEXT CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Appliances
CREATE TABLE appliances (
    id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES appliance_categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    status TEXT CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Services
CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    appliance_id INTEGER REFERENCES appliances(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES service_providers(id) ON DELETE CASCADE,
    service_name TEXT NOT NULL,
    description TEXT,
    starting_price NUMERIC,
    status TEXT CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bookings
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_number TEXT UNIQUE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    provider_id UUID REFERENCES service_providers(id) ON DELETE SET NULL,
    technician_id UUID REFERENCES technicians(id) ON DELETE SET NULL,
    appliance_id INTEGER REFERENCES appliances(id) ON DELETE SET NULL,
    service_id INTEGER REFERENCES services(id) ON DELETE SET NULL,
    problem TEXT,
    description TEXT,
    image_url TEXT,
    service_type TEXT CHECK (service_type IN ('home_visit', 'shop_service')) DEFAULT 'home_visit',
    address TEXT,
    city TEXT,
    pincode TEXT,
    preferred_date DATE,
    preferred_time TEXT,
    expected_visit_time TIMESTAMPTZ,
    estimated_cost NUMERIC,
    final_cost NUMERIC,
    booking_status TEXT CHECK (booking_status IN ('requested', 'accepted', 'rejected', 'technician_assigned', 'technician_on_way', 'inspection_started', 'repair_in_progress', 'repair_completed', 'payment_pending', 'payment_completed', 'closed', 'cancelled')) DEFAULT 'requested',
    payment_status TEXT CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Booking Status History
CREATE TABLE booking_status_history (
    id SERIAL PRIMARY KEY,
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    status TEXT NOT NULL,
    note TEXT,
    updated_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    amount NUMERIC NOT NULL,
    payment_method TEXT CHECK (payment_method IN ('cash', 'demo_online')) NOT NULL,
    transaction_id TEXT UNIQUE,
    payment_status TEXT CHECK (payment_status IN ('pending', 'completed', 'failed')) DEFAULT 'pending',
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reviews
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES service_providers(id) ON DELETE CASCADE,
    technician_id UUID REFERENCES technicians(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    review TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Addresses
CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    pincode TEXT NOT NULL,
    latitude NUMERIC,
    longitude NUMERIC,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES service_providers(id) ON DELETE CASCADE,
    admin_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create a function to auto-generate booking numbers (ES-YYYY-XXXXXX)
CREATE OR REPLACE FUNCTION generate_booking_number() RETURNS TRIGGER AS $$
DECLARE
    year_prefix TEXT;
    next_id INTEGER;
BEGIN
    year_prefix := 'ES-' || to_char(CURRENT_DATE, 'YYYY') || '-';
    
    -- Getting a simple sequence equivalent for the year
    SELECT COALESCE(MAX(SUBSTRING(booking_number FROM 9 FOR 6)::INTEGER), 0) + 1
    INTO next_id
    FROM bookings
    WHERE booking_number LIKE year_prefix || '%';
    
    NEW.booking_number := year_prefix || lpad(next_id::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_booking_number
BEFORE INSERT ON bookings
FOR EACH ROW
WHEN (NEW.booking_number IS NULL)
EXECUTE FUNCTION generate_booking_number();
