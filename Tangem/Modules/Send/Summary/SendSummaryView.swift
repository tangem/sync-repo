//
//  SendSummaryView.swift
//  Send
//
//  Created by Andrey Chukavin on 30.10.2023.
//

import SwiftUI

struct SendSummaryView: View {
    let height = 150.0
    let namespace: Namespace.ID
    let viewModel: SendSummaryViewModel

    @SceneStorage("ContentView.selectedProduct") var animateOther = true

    @State var showAmount = true
    @State var showDestination = true

    var body: some View {
        VStack(spacing: 20) {
            if showAmount {
                Button(action: {
                    viewModel.didTapSummary(for: .amount)
                }, label: {
                    Color.clear
                        .frame(maxHeight: height)
                        .border(Color.green, width: 5)
                        .overlay(
                            VStack {
                                HStack {
                                    Text(viewModel.amountText)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                            }
                            .padding()
                        )
                        .matchedGeometryEffect(id: "amount", in: namespace)
                })
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .opacity.combined(with: .scale)))
            }

            if showDestination {
                Button(action: {
                    viewModel.didTapSummary(for: .destination)
                }, label: {
                    Color.clear
                        .frame(maxHeight: height)
                        .border(Color.purple, width: 5)
                        .overlay(
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(viewModel.destinationText)
                                        .lineLimit(1)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                            }
                            .padding()
                        )
                        .matchedGeometryEffect(id: "dest", in: namespace)

                })

                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .opacity.combined(with: .scale).combined(with: .offset(y: -height - 20))))
            }

            Button(action: {
                if animateOther {
                    withAnimation(.easeOut(duration: 0.1 * 1)) {
                        showAmount = false
                        showDestination = false
                    }
                }
                viewModel.didTapSummary(for: .fee)
            }, label: {
                Color.clear
                    .frame(maxHeight: height)
                    .border(Color.blue, width: 5)
                    .overlay(
                        VStack(alignment: .leading) {
                            HStack {
                                Text(viewModel.feeText)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                        }
                        .padding()
                    )
                    .transition(.identity)
                    .matchedGeometryEffect(id: "fee", in: namespace)
            })

            Spacer()

            Button {
                withAnimation {
                    showAmount.toggle()
                }
            } label: {
                Text("Toggle amount")
            }

            Toggle(isOn: $animateOther, label: {
                Text("Animate other")
            })

            Button(action: viewModel.send) {
                Text("Send")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .animation(nil, value: UUID())
            .transaction { transaction in
                transaction.animation = nil
                transaction.disablesAnimations = true
            }
        }
        .padding(.horizontal)
    }
}

private enum S {
    @Namespace static var namespace // <- This
}

// #Preview {
//    SendSummaryView(namespace: S.namespace, sendViewModel: SendViewModel(coordinator: MockSendRoutable()))
// }
