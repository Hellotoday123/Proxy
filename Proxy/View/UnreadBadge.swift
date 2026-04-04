//
//  UnreadBadge.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-03-09.
//

import Foundation
import SwiftUI

struct UnreadBadge: View {

    let count: Int

    var body: some View {

        if count > 0 {

            Text(count > 10 ? "10+" : "\(count)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .frame(height: 20)
                .background(Color.red)
                .clipShape(Capsule())
        }
    }
}
