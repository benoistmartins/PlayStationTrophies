//
//  PSNLoginView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import SwiftUI

struct PSNLoginView: View {
    @ObservedObject var viewModel: PSNAuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var showGetToken = false

    var body: some View {
        NavigationStack {
            ZStack {
                PSNWebView(
                    onNpssoReceived: { npsso in
                        viewModel.onNpssoReceived(npsso)
                    },
                    onError: { error in
                        viewModel.error = error
                    },
                    showGetToken: $showGetToken
                )

                if isLoading || viewModel.isLoading {
                    ProgressView("Loading PlayStation Network...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Sign in to PSN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showGetToken = true
                    } label: {
                        Text("Get token")
                            .font(.caption.bold())
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .psnWebViewDidFinishLoad)) { _ in
                isLoading = false
            }
            .onChange(of: viewModel.isAuthenticated) { _, authenticated in
                if authenticated { dismiss() }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.clearError() } }
            )) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
    }
}