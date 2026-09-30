-- supabase/storage.sql

-- Insert storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES ('appliance-images', 'appliance-images', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('provider-images', 'provider-images', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('technician-images', 'technician-images', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('documents', 'documents', false); -- Private bucket for verification docs

-- Set up Storage Policies

-- appliance-images (Public Read, Authenticated Insert/Update for own uploads)
CREATE POLICY "Public Read Appliance Images" ON storage.objects FOR SELECT USING (bucket_id = 'appliance-images');
CREATE POLICY "Auth Insert Appliance Images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'appliance-images' AND auth.role() = 'authenticated');
CREATE POLICY "Auth Update Appliance Images" ON storage.objects FOR UPDATE USING (bucket_id = 'appliance-images' AND auth.uid() = owner);

-- provider-images (Public Read, Authenticated Insert/Update for own uploads)
CREATE POLICY "Public Read Provider Images" ON storage.objects FOR SELECT USING (bucket_id = 'provider-images');
CREATE POLICY "Auth Insert Provider Images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'provider-images' AND auth.role() = 'authenticated');
CREATE POLICY "Auth Update Provider Images" ON storage.objects FOR UPDATE USING (bucket_id = 'provider-images' AND auth.uid() = owner);

-- technician-images (Public Read, Authenticated Insert/Update for own uploads)
CREATE POLICY "Public Read Technician Images" ON storage.objects FOR SELECT USING (bucket_id = 'technician-images');
CREATE POLICY "Auth Insert Technician Images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'technician-images' AND auth.role() = 'authenticated');
CREATE POLICY "Auth Update Technician Images" ON storage.objects FOR UPDATE USING (bucket_id = 'technician-images' AND auth.uid() = owner);

-- documents (Private: Admin Read All, Provider Read/Write Own)
CREATE POLICY "Admin Read Documents" ON storage.objects FOR SELECT USING (bucket_id = 'documents' AND (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin') OR auth.uid() = owner));
CREATE POLICY "Auth Insert Documents" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'documents' AND auth.role() = 'authenticated');
CREATE POLICY "Auth Update Documents" ON storage.objects FOR UPDATE USING (bucket_id = 'documents' AND auth.uid() = owner);
