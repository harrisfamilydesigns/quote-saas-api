# Clear existing data
puts "Clearing existing data..."
Quote.destroy_all
MaterialRequest.destroy_all
Project.destroy_all
User.destroy_all
Contractor.destroy_all
Supplier.destroy_all

# Create contractors
puts "Creating contractors..."
contractors = [
  { name: "ABC Builders", contact_email: "info@abcbuilders.com" },
  { name: "XYZ Construction", contact_email: "contact@xyzconstruction.com" }
]

created_contractors = Contractor.create!(contractors)

# Create suppliers
puts "Creating suppliers..."
suppliers = [
  { name: "Building Materials Inc", contact_email: "sales@bminc.com" },
  { name: "Lumber Supplies Co", contact_email: "info@lumbersupplies.com" },
  { name: "Quality Hardware", contact_email: "sales@qualityhardware.com" }
]

created_suppliers = Supplier.create!(suppliers)

# Create users
puts "Creating users..."
users = [
  # Contractor users
  { email: "contractor1@example.com", password: "password", role: "contractor", contractor: created_contractors[0] },
  { email: "contractor2@example.com", password: "password", role: "contractor", contractor: created_contractors[1] },
  
  # Supplier users
  { email: "supplier1@example.com", password: "password", role: "supplier", supplier: created_suppliers[0] },
  { email: "supplier2@example.com", password: "password", role: "supplier", supplier: created_suppliers[1] },
  { email: "supplier3@example.com", password: "password", role: "supplier", supplier: created_suppliers[2] },
  
  # Admin user
  { email: "admin@example.com", password: "password", role: "admin" }
]

created_users = User.create!(users)

# Create projects
puts "Creating projects..."
projects = [
  # Projects for ABC Builders
  { 
    name: "Residential Renovation", 
    description: "Full renovation of a 2-story residential home", 
    status: "open", 
    contractor: created_contractors[0] 
  },
  { 
    name: "Garage Addition", 
    description: "Adding a 2-car garage to existing property", 
    status: "draft", 
    contractor: created_contractors[0] 
  },
  
  # Projects for XYZ Construction
  { 
    name: "Commercial Office Buildout", 
    description: "Interior buildout of 5000 sq ft office space", 
    status: "open", 
    contractor: created_contractors[1] 
  },
  { 
    name: "Retail Store Renovation", 
    description: "Renovating storefront and interior of retail location", 
    status: "closed", 
    contractor: created_contractors[1] 
  }
]

created_projects = Project.create!(projects)

# Create material requests
puts "Creating material requests..."
material_requests = [
  # Material requests for Residential Renovation
  { 
    description: "Hardwood flooring, oak, 3/4\" thick", 
    quantity: 1000, 
    unit: "sqft", 
    project: created_projects[0] 
  },
  { 
    description: "Kitchen cabinets, maple, shaker style", 
    quantity: 10, 
    unit: "piece", 
    project: created_projects[0] 
  },
  
  # Material requests for Garage Addition
  { 
    description: "Framing lumber, 2x4, pressure treated", 
    quantity: 500, 
    unit: "ft", 
    project: created_projects[1] 
  },
  
  # Material requests for Commercial Office Buildout
  { 
    description: "Commercial carpet tiles, 24\"x24\"", 
    quantity: 5000, 
    unit: "sqft", 
    project: created_projects[2] 
  },
  { 
    description: "Acoustic ceiling tiles, 2'x2'", 
    quantity: 200, 
    unit: "piece", 
    project: created_projects[2] 
  },
  
  # Material requests for Retail Store Renovation
  { 
    description: "Storefront glass, tempered, 1/2\" thick", 
    quantity: 300, 
    unit: "sqft", 
    project: created_projects[3] 
  }
]

created_material_requests = MaterialRequest.create!(material_requests)

# Create quotes
puts "Creating quotes..."
quotes = [
  # Quotes for Hardwood flooring
  { 
    price: 5500, 
    lead_time_days: 14, 
    status: "pending", 
    material_request: created_material_requests[0], 
    supplier: created_suppliers[0] 
  },
  { 
    price: 6200, 
    lead_time_days: 7, 
    status: "pending", 
    material_request: created_material_requests[0], 
    supplier: created_suppliers[1] 
  },
  
  # Quotes for Kitchen cabinets
  { 
    price: 8000, 
    lead_time_days: 21, 
    status: "accepted", 
    material_request: created_material_requests[1], 
    supplier: created_suppliers[2] 
  },
  
  # Quotes for Framing lumber
  { 
    price: 1200, 
    lead_time_days: 5, 
    status: "pending", 
    material_request: created_material_requests[2], 
    supplier: created_suppliers[1] 
  },
  
  # Quotes for Commercial carpet tiles
  { 
    price: 15000, 
    lead_time_days: 30, 
    status: "pending", 
    material_request: created_material_requests[3], 
    supplier: created_suppliers[0] 
  },
  { 
    price: 12500, 
    lead_time_days: 45, 
    status: "accepted", 
    material_request: created_material_requests[3], 
    supplier: created_suppliers[2] 
  },
  
  # Quotes for Acoustic ceiling tiles
  { 
    price: 2000, 
    lead_time_days: 10, 
    status: "rejected", 
    material_request: created_material_requests[4], 
    supplier: created_suppliers[0] 
  },
  { 
    price: 1800, 
    lead_time_days: 15, 
    status: "accepted", 
    material_request: created_material_requests[4], 
    supplier: created_suppliers[2] 
  },
  
  # Quotes for Storefront glass
  { 
    price: 9000, 
    lead_time_days: 21, 
    status: "accepted", 
    material_request: created_material_requests[5], 
    supplier: created_suppliers[2] 
  }
]

Quote.create!(quotes)

# Create supplier invitations
puts "Creating supplier invitations..."
# Invite suppliers to material requests
material_request_suppliers = [
  # Invite Building Materials Inc and Lumber Supplies Co to Hardwood flooring request
  {
    material_request: created_material_requests[0],
    supplier: created_suppliers[0]
  },
  {
    material_request: created_material_requests[0],
    supplier: created_suppliers[1]
  },
  
  # Invite Quality Hardware to Kitchen cabinets request
  {
    material_request: created_material_requests[1],
    supplier: created_suppliers[2]
  },
  
  # Invite Lumber Supplies Co to Framing lumber request
  {
    material_request: created_material_requests[2],
    supplier: created_suppliers[1]
  },
  
  # Invite Building Materials Inc and Quality Hardware to Commercial carpet tiles request
  {
    material_request: created_material_requests[3],
    supplier: created_suppliers[0]
  },
  {
    material_request: created_material_requests[3],
    supplier: created_suppliers[2]
  },
  
  # Invite Building Materials Inc and Quality Hardware to Acoustic ceiling tiles request
  {
    material_request: created_material_requests[4],
    supplier: created_suppliers[0]
  },
  {
    material_request: created_material_requests[4],
    supplier: created_suppliers[2]
  },
  
  # Invite Quality Hardware to Storefront glass request
  {
    material_request: created_material_requests[5],
    supplier: created_suppliers[2]
  }
]

MaterialRequestSupplier.create!(material_request_suppliers)

puts "Seeding completed!"
