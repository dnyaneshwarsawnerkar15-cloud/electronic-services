-- supabase/rls.sql

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE technicians ENABLE ROW LEVEL SECURITY;
ALTER TABLE appliance_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE appliances ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE booking_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Helper Functions
CREATE OR REPLACE FUNCTION is_admin() RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_provider() RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'provider'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_provider_id() RETURNS UUID AS $$
DECLARE
    prov_id UUID;
BEGIN
  SELECT id INTO prov_id FROM service_providers WHERE owner_id = auth.uid() LIMIT 1;
  RETURN prov_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Profiles
CREATE POLICY "Users can view their own profile" ON profiles FOR SELECT USING (auth.uid() = id OR is_admin());
CREATE POLICY "Users can update their own profile" ON profiles FOR UPDATE USING (auth.uid() = id OR is_admin());
CREATE POLICY "Admins can view all profiles" ON profiles FOR SELECT USING (is_admin());
CREATE POLICY "Admins can insert profiles" ON profiles FOR INSERT WITH CHECK (is_admin());
CREATE POLICY "Admins can update all profiles" ON profiles FOR UPDATE USING (is_admin());
CREATE POLICY "Admins can delete profiles" ON profiles FOR DELETE USING (is_admin());

-- Service Providers
CREATE POLICY "Anyone can view approved providers" ON service_providers FOR SELECT USING (status = 'approved' OR is_admin() OR owner_id = auth.uid());
CREATE POLICY "Providers can create their profile" ON service_providers FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Providers can update their profile" ON service_providers FOR UPDATE USING (auth.uid() = owner_id OR is_admin());
CREATE POLICY "Admins can manage providers" ON service_providers FOR ALL USING (is_admin());

-- Technicians
CREATE POLICY "Anyone can view active technicians of approved providers" ON technicians FOR SELECT USING (status = 'active' OR is_admin() OR provider_id = get_provider_id());
CREATE POLICY "Providers can manage their technicians" ON technicians FOR ALL USING (provider_id = get_provider_id() OR is_admin());

-- Appliance Categories
CREATE POLICY "Anyone can view active categories" ON appliance_categories FOR SELECT USING (status = 'active' OR is_admin());
CREATE POLICY "Admins can manage categories" ON appliance_categories FOR ALL USING (is_admin());

-- Appliances
CREATE POLICY "Anyone can view active appliances" ON appliances FOR SELECT USING (status = 'active' OR is_admin());
CREATE POLICY "Admins can manage appliances" ON appliances FOR ALL USING (is_admin());

-- Services
CREATE POLICY "Anyone can view active services" ON services FOR SELECT USING (status = 'active' OR is_admin() OR provider_id = get_provider_id());
CREATE POLICY "Providers can manage their services" ON services FOR ALL USING (provider_id = get_provider_id() OR is_admin());

-- Bookings
CREATE POLICY "Users can view their own bookings" ON bookings FOR SELECT USING (user_id = auth.uid() OR provider_id = get_provider_id() OR is_admin());
CREATE POLICY "Users can create bookings" ON bookings FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update their own bookings" ON bookings FOR UPDATE USING (user_id = auth.uid() OR provider_id = get_provider_id() OR is_admin());

-- Booking Status History
CREATE POLICY "Users can view their booking history" ON booking_status_history FOR SELECT USING (
    EXISTS (SELECT 1 FROM bookings WHERE id = booking_status_history.booking_id AND (user_id = auth.uid() OR provider_id = get_provider_id() OR is_admin()))
);
CREATE POLICY "Providers and Admins can add history" ON booking_status_history FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM bookings WHERE id = booking_status_history.booking_id AND (provider_id = get_provider_id() OR is_admin()))
);

-- Payments
CREATE POLICY "Users can view their payments" ON payments FOR SELECT USING (user_id = auth.uid() OR is_admin());
CREATE POLICY "Users can create payments" ON payments FOR INSERT WITH CHECK (user_id = auth.uid() OR is_admin());
CREATE POLICY "Admins can update payments" ON payments FOR UPDATE USING (is_admin());

-- Reviews
CREATE POLICY "Anyone can view reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Users can create reviews for completed bookings" ON reviews FOR INSERT WITH CHECK (
    user_id = auth.uid() AND EXISTS (SELECT 1 FROM bookings WHERE id = booking_id AND user_id = auth.uid() AND booking_status = 'closed')
);
CREATE POLICY "Users can update their reviews" ON reviews FOR UPDATE USING (user_id = auth.uid() OR is_admin());
CREATE POLICY "Admins can delete reviews" ON reviews FOR DELETE USING (is_admin());

-- Addresses
CREATE POLICY "Users can manage their addresses" ON addresses FOR ALL USING (user_id = auth.uid() OR is_admin());

-- Notifications
CREATE POLICY "Users can view their notifications" ON notifications FOR SELECT USING (user_id = auth.uid() OR provider_id = get_provider_id() OR is_admin());
CREATE POLICY "System can create notifications" ON notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update their notifications (mark as read)" ON notifications FOR UPDATE USING (user_id = auth.uid() OR provider_id = get_provider_id() OR is_admin());
