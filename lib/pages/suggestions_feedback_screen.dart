import 'package:flutter/material.dart';
import '../theme/theme.dart'; // Import your custom theme for font consistency

class SuggestionsFeedbackScreen extends StatelessWidget {
  const SuggestionsFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar is removed to match the design, similar to Homepage
      body: Stack( // Use Stack to place the title "Saran Dan Kesan"
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0), // Padding for the content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60), // Space for the top title

                // "Feedback" Header with three dots
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0), // No extra horizontal padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 24, // Adjust font size as per design
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Dark color for Feedback title
                          fontFamily: 'jakarta-sans', // Apply custom font
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        color: Colors.grey,
                        onPressed: () {
                          // Handle menu icon tap
                          print('Feedback menu tapped');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Spacing after Feedback header

                // Rate Experience Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Rate experience',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontFamily: 'jakarta-sans',
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Large Emoji (placeholder for a single selected emoji)
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.yellow[200], // Light yellow background
                        child: const Text(
                          '😐', // Neutral emoji as default
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Smaller Emoji Options with labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildEmojiOption('😡', 'Marah', Colors.red, Colors.yellow),
                          _buildEmojiOption('😟', 'Kurang', Colors.orange, Colors.yellow),
                          _buildEmojiOption('😐', 'Netral', Colors.yellow, Colors.yellow),
                          _buildEmojiOption('😀', 'Senang', Colors.green, Colors.yellow),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Colored Horizontal Bar (representing a rating or progress)
                      Container(
                        height: 5,
                        width: MediaQuery.of(context).size.width * 0.7, // Adjust width
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red,
                              Colors.orange,
                              Colors.yellow,
                              Colors.lightGreen,
                              Colors.green,
                            ],
                            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40), // Spacing before lorem ipsum

                // Lorem Ipsum Text Block
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontFamily: 'jakarta-sans',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20), // Additional space at bottom
              ],
            ),
          ),
          // "Saran Dan Kesan" Title (positioned at top-left)
          
        ],
      ),
      // Bottom Navigation Bar is assumed to be handled by the parent Homepage widget
    );
  }

  Widget _buildEmojiOption(String emoji, String label, Color emojiColor, Color borderColor) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Handle emoji selection
            print('$label emoji tapped!');
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // White background for the emoji circle
              border: Border.all(color: borderColor, width: 2), // Yellow border
            ),
            child: Text(
              emoji,
              style: TextStyle(fontSize: 30, color: emojiColor), // Emoji itself
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: 'jakarta-sans',
          ),
        ),
      ],
    );
  }
}