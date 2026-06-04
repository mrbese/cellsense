import SwiftUI
import PhotosUI
import VisionKit
import PDFKit

struct UtilityStepView: View {
    @Bindable var model: CalculationModel
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showCameraScanner = false
    @State private var showFileImporter = false
    @State private var isScanning = false
    @State private var showScanAlert = false
    @State private var scanAlertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header description
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Utility")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("Select your electric utility and current rate plan")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 10)
            
            // Scan / Upload Bill Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Autofill with Bill Scan (Optional)")
                    .font(.caption.bold())
                    .foregroundColor(Color(red: 0.0, green: 0.83, blue: 0.67))
                
                // Primary Camera Scan Button
                Button(action: {
                    if VNDocumentCameraViewController.isSupported {
                        showCameraScanner = true
                    } else {
                        scanAlertMessage = "Camera document scanning is not supported on this device/simulator. Please use the Files or Photos options."
                        showScanAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.text.viewfinder")
                        Text("Scan Bill with Camera")
                            .font(.footnote.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.0, green: 0.83, blue: 0.67))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
                
                HStack(spacing: 12) {
                    // Photos Library button
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Photos Library")
                                .font(.caption.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    
                    // Files App button
                    Button(action: {
                        showFileImporter = true
                    }) {
                        HStack {
                            Image(systemName: "folder.badge.plus")
                            Text("Files App")
                                .font(.caption.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
                
                if isScanning {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(Color(red: 0.0, green: 0.83, blue: 0.67))
                        Text("Extracting information from bill...")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.03))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            
            // Utility Selection Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Utility Company")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                Picker("Utility", selection: $model.selectedUtility) {
                    Text("Select utility...").tag(nil as Utility?)
                    ForEach(DataManager.shared.utilities) { utility in
                        Text(utility.name).tag(utility as Utility?)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(white: 0.15))
                .cornerRadius(8)
                .accentColor(.white)
            }
            
            // Rate Plan Selection Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Rate Plan")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                Picker("Rate Plan", selection: $model.selectedRatePlan) {
                    if let utility = model.selectedUtility {
                        let plans = DataManager.shared.getRatePlans(forUtilityId: utility.id)
                        ForEach(plans) { plan in
                            Text(plan.name).tag(plan as RatePlan?)
                        }
                    } else {
                        Text("Select a utility first...").tag(nil as RatePlan?)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(white: 0.15))
                .cornerRadius(8)
                .accentColor(.white)
                .disabled(model.selectedUtility == nil)
            }
            
            // Average Monthly Bill
            VStack(alignment: .leading, spacing: 8) {
                Text("Avg Monthly Bill")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    Text("$")
                        .foregroundColor(.white)
                        .font(.body.bold())
                    
                    TextField("200", value: $model.monthlyBill, format: .number)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(white: 0.15))
                .cornerRadius(8)
                
                Text("Before taxes and fees")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            // Solar Panels Toggle
            VStack(alignment: .leading, spacing: 8) {
                Text("Solar Panels?")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                Toggle(isOn: $model.hasSolar) {
                    Text("I have rooftop solar")
                        .foregroundColor(.white)
                }
                .tint(Color(red: 0.0, green: 0.83, blue: 0.67))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(white: 0.15))
                .cornerRadius(8)
            }
            
            // Conditional NEM 3.0 Callout
            if model.hasSolar, let utility = model.selectedUtility, utility.hasNem3 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("☀️")
                        Text("NEM 3.0 Detected")
                            .font(.subheadline.bold())
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0)) // Golden solar yellow
                    }
                    
                    Text("Your utility uses NEM 3.0 (Net Billing Tariff). Solar export rates average ~$0.05-0.08/kWh midday — much lower than retail. A battery lets you store solar and sell at peak rates instead, dramatically improving your ROI.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(4)
                }
                .padding(14)
                .background(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.08))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.2), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onChange(of: selectedItem) { oldItem, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    handleScannedImage(image)
                }
            }
        }
        .sheet(isPresented: $showCameraScanner) {
            DocumentScannerView(
                isPresented: $showCameraScanner,
                onRecognize: { image in
                    handleScannedImage(image)
                },
                onError: { error in
                    scanAlertMessage = "Scanner error: \(error.localizedDescription)"
                    showScanAlert = true
                },
                onCancel: {}
            )
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.pdf, .image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                handleImportedFile(at: url)
            case .failure(let error):
                scanAlertMessage = "File import error: \(error.localizedDescription)"
                showScanAlert = true
            }
        }
        .alert("Bill Scanner", isPresented: $showScanAlert) {
            Button("OK", role: .cancel) {
                selectedItem = nil
            }
        } message: {
            Text(scanAlertMessage)
        }
    }
    
    private func handleScannedImage(_ image: UIImage) {
        isScanning = true
        BillParser.shared.parseImage(image) { result in
            DispatchQueue.main.async {
                isScanning = false
                applyParseResult(result)
            }
        }
    }
    
    private func handleImportedFile(at url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            scanAlertMessage = "Unable to access the selected file due to security permissions."
            showScanAlert = true
            return
        }
        
        isScanning = true
        let isPDF = url.pathExtension.lowercased() == "pdf"
        
        if isPDF {
            DispatchQueue.global(qos: .userInitiated).async {
                let pdf = PDFDocument(url: url)
                url.stopAccessingSecurityScopedResource()
                
                if let pdf = pdf {
                    var pagesText: [String] = []
                    for i in 0..<pdf.pageCount {
                        if let page = pdf.page(at: i), let pageText = page.string {
                            pagesText.append(pageText)
                        }
                    }
                    
                    let result = BillParser.shared.analyzeText(pagesText)
                    
                    DispatchQueue.main.async {
                        self.isScanning = false
                        self.applyParseResult(result)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isScanning = false
                        self.scanAlertMessage = "Failed to load the PDF document."
                        self.showScanAlert = true
                    }
                }
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let data = try? Data(contentsOf: url)
                url.stopAccessingSecurityScopedResource()
                
                if let data = data, let image = UIImage(data: data) {
                    BillParser.shared.parseImage(image) { result in
                        DispatchQueue.main.async {
                            self.isScanning = false
                            self.applyParseResult(result)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isScanning = false
                        self.scanAlertMessage = "Failed to load the image file."
                        self.showScanAlert = true
                    }
                }
            }
        }
    }
    
    private func applyParseResult(_ result: BillParser.ParseResult) {
        var changes: [String] = []
        
        if let amt = result.amount {
            model.monthlyBill = amt
            changes.append("• Monthly bill: $\(Int(amt))")
        }
        
        if let utilId = result.utilityId,
           let util = DataManager.shared.utilities.first(where: { $0.id == utilId }) {
            model.selectedUtility = util
            changes.append("• Utility: \(util.shortName)")
            
            if let planId = result.ratePlanId,
               let plan = DataManager.shared.getRatePlans(forUtilityId: utilId).first(where: { $0.id == planId }) {
                model.selectedRatePlan = plan
                changes.append("• Rate plan: \(plan.name)")
            }
        }
        
        if changes.isEmpty {
            scanAlertMessage = "We couldn't recognize the utility, rate plan, or bill amount from the document. Please verify the document is readable and try again."
        } else {
            scanAlertMessage = "Successfully recognized and auto-filled:\n\n" + changes.joined(separator: "\n")
        }
        showScanAlert = true
    }
}
