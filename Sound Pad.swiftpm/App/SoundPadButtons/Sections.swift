import SwiftUI

struct SectionView<Content:View>: View {
    var sectionName: String
    let columns = [GridItem(.adaptive(minimum: 65, maximum: .infinity))]
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack (spacing: 0) {
            Text(sectionName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: columns) {
                content
                    .padding(5)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .padding(10)
            .background (
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.sectionColor)
            )
            .accessibilityElement(children: .contain)
        }
    }
}

struct Beats<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        SectionView(sectionName: "Beats") {
            content
        }
    }
}

struct Bass<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        SectionView(sectionName: "Bass") {
            content
        }
    }
}

struct Melodic<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        SectionView(sectionName: "Melodic") {
            content
        }
    }
}

struct Ambient<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        SectionView(sectionName: "Ambient") {
            content
        }
    }
}

struct SoundFX<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        SectionView(sectionName: "SoundFX") {
            content
        }
    }
}
