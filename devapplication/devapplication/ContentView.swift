import SwiftUI
import CallKit
import Foundation


enum ContactType: String, CaseIterable, Identifiable {
    case emergency = "Emergency"
    case tollFree = "Toll-Free"
    case custom = "Custom"
    
    var id: String { self.rawValue }
}

struct EmergencyContact: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String
    let type: ContactType
}


var emergencyContacts: [EmergencyContact] = [
    EmergencyContact(name: "Fire Department", phoneNumber: "101", type: .emergency),
    EmergencyContact(name: "Police", phoneNumber: "100", type: .emergency),
    EmergencyContact(name: "Ambulance", phoneNumber: "102", type: .emergency),
    EmergencyContact(name: "Child Helpline", phoneNumber: "1098", type: .tollFree),
    EmergencyContact(name: "Women Helpline", phoneNumber: "181", type: .tollFree),
    EmergencyContact(name: "Disaster Management", phoneNumber: "1078", type: .tollFree),
    EmergencyContact(name: "Medical Emergency", phoneNumber: "108", type: .tollFree),
    EmergencyContact(name: "Railway Helpline", phoneNumber: "139", type: .tollFree),
    EmergencyContact(name: "Anti-Poison Helpline", phoneNumber: "1066", type: .tollFree),
    EmergencyContact(name: "Senior Citizen Helpline", phoneNumber: "1291", type: .tollFree),
    EmergencyContact(name: "Road Accident Emergency", phoneNumber: "1073", type: .tollFree),
    EmergencyContact(name: "Electricity Emergency", phoneNumber: "1912", type: .tollFree),
    EmergencyContact(name: "Gas Leak Emergency", phoneNumber: "1906", type: .tollFree),
    EmergencyContact(name: "National Consumer Helpline", phoneNumber: "1800-11-4000", type: .tollFree),
    EmergencyContact(name: "COVID-19 Helpline", phoneNumber: "1075", type: .tollFree),
    EmergencyContact(name: "Women in Distress", phoneNumber: "1091", type: .tollFree),
    EmergencyContact(name: "AIDS Helpline", phoneNumber: "1097", type: .tollFree),
    EmergencyContact(name: "Earthquake Helpline", phoneNumber: "1092", type: .tollFree),
    EmergencyContact(name: "Tourist Helpline", phoneNumber: "1363", type: .tollFree),
    EmergencyContact(name: "Railway Accident Emergency", phoneNumber: "1072", type: .tollFree)
]

struct ContentView: View {
    @State private var searchText = ""
    @State private var showingAddContact = false
    @State private var contacts = emergencyContacts
    @State private var selectedContact: EmergencyContact?
    @State private var showingInfo = false
    
    var filteredContacts: [EmergencyContact] {
            let sortedContacts = contacts.sorted { $0.name.lowercased() < $1.name.lowercased() }
            if searchText.isEmpty {
                return sortedContacts
            } else {
                return sortedContacts.filter {
                    $0.name.lowercased().contains(searchText.lowercased()) ||
                    $0.phoneNumber.lowercased().contains(searchText.lowercased())
                }
            }
        }

    var body: some View {
            NavigationView {
                VStack {
                    SearchBar(text: $searchText)
                    List {
                        ForEach(filteredContacts) { contact in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(contact.name)
                                        .font(.headline)
                                    Text(contact.type.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    makeCall(phoneNumber: contact.phoneNumber)
                                }) {
                                    EmptyView()
                                }
                                .buttonStyle(PlainButtonStyle()) // Hides the button
                                Button(action: {
                                    selectedContact = contact
                                    showingInfo = true
                                }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle()) // Makes the entire row tappable
                            .onTapGesture {
                                makeCall(phoneNumber: contact.phoneNumber)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .navigationBarTitle("Important Contacts")
                .navigationBarItems(trailing:
                    Button(action: {
                        showingAddContact = true
                    }) {
                        Image(systemName: "plus")
                    }
                )
                .preferredColorScheme(.dark)
                .sheet(isPresented: $showingAddContact) {
                    AddContactView(contacts: $contacts)
                }
                .sheet(item: $selectedContact) { contact in
                    ContactInfoView(contact: contact)
                }
            }
        }

    func makeCall(phoneNumber: String) {
        let formattedPhoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(formattedPhoneNumber)") {
            print("Attempting to call \(formattedPhoneNumber)")
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url) { success in
                    if success {
                        print("Successfully initiated call to \(formattedPhoneNumber)")
                    } else {
                        print("Failed to initiate call to \(formattedPhoneNumber)")
                    }
                }
            } else {
                print("Cannot open URL: \(url)")
            }
        } else {
            print("Invalid URL for phone number: \(formattedPhoneNumber)")
        }
    }
}

struct AddContactView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var contacts: [EmergencyContact]
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var selectedType = ContactType.custom

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Info")) {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    Picker("Type", selection: $selectedType) {
                        ForEach(ContactType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                Section {
                    Button("Add Contact") {
                        let newContact = EmergencyContact(name: name, phoneNumber: phoneNumber, type: selectedType)
                        contacts.append(newContact)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationBarTitle("Add Contact", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ContactInfoView: View {
    let contact: EmergencyContact
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text(contact.name)
                .font(.largeTitle)
                .padding()
            Text(contact.phoneNumber)
                .font(.title)
                .padding()
            Text(contact.type.rawValue)
                .font(.title2)
                .padding()
            Spacer()
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .padding()
        .navigationBarTitle("Contact Info", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle")
            }
        )
    }
}



struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
            
        }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        text = searchText
    }
}

func makeCoordinator() -> Coordinator {
    return Coordinator(text: $text)
}

func makeUIView(context: Context) -> UISearchBar {
    let searchBar = UISearchBar(frame: .zero)
    searchBar.delegate = context.coordinator
    searchBar.placeholder = "Search Contacts"
    return searchBar
}

func updateUIView(_ uiView: UISearchBar, context: Context) {
    uiView.text = text
}
}

struct ContentView_Previews: PreviewProvider {
static var previews: some View {
    ContentView()
}
}

// Functionality for deleting custom contacts
extension ContentView {
func deleteContact(_ contact: EmergencyContact) {
    contacts.removeAll { $0.id == contact.id }
}
}

