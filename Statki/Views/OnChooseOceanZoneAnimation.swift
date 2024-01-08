//
//  OnChooseOceanZoneAnimation.swift
//  Statki
//
//  Created by Krzysztof Caban on 08/01/2024.
//

import SwiftUI

struct OnChooseOceanZoneAnimation: View {
    @Binding var zoneState: OceanZoneState
    private let oceanSquare = CGSize(width: 0.95, height: 0.95)
    @State private var isAnimating = false
    @State private var triangleOffset: CGSize = CGSize(width: 0, height: 200)
    @State private var triangleScale: CGFloat = 2.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isAnimating {
                    switch zoneState {
                    case .hit:
                        ScaledShape(shape: Rectangle(), scale: oceanSquare)
                            .fill(.gray)
                            .opacity(0.6)
                            .overlay(
                                FireAnimation().frame(width: 50, height: 50)
                            )
                    default:
                        ScaledShape(shape: Rectangle(), scale: oceanSquare)
                            .fill(.blue)
                            .opacity(0.8)
                            .overlay(
                                WaterAnimation().frame(width: 50, height: 50)
                            )
                    }

                } else {
                    RocketShape()
                        .fill(Color.black)
                        .frame(width: 50, height: 50)
                        .scaleEffect(triangleScale)
                        .offset(triangleOffset)
                        .rotationEffect(.degrees(180))
                        .onAppear {
                            animateRocket(geometry: geometry)
                        }
                }
            }
        }
    }

    func animateRocket(geometry: GeometryProxy) {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            triangleOffset = CGSize(width: geometry.size.width / 2 - 25, height: geometry.size.height / 2 - 25)
            triangleScale = 0.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isAnimating = true
            }
        }
    }
}
