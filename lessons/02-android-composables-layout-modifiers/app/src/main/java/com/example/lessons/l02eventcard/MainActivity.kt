package com.example.lessons.l02eventcard

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
// Everything today's exercises need is already imported (unused imports are only warnings).
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MaterialTheme {
                Surface(Modifier.fillMaxSize()) { LessonScreen(Modifier.safeDrawingPadding()) }
            }
        }
    }
}

/** The whole screen. Today it only shows one card. */
@Composable
fun LessonScreen(modifier: Modifier = Modifier) {
    // The screen fills the window; its child card can wrap its own height.
    Box(modifier.fillMaxSize(), contentAlignment = Alignment.TopStart) {
        EventCard()
    }
}

/** A meetup card: date tile + title/details + RSVP in a row, description underneath. */
@Composable
fun EventCard(modifier: Modifier = Modifier) {
    // TODO (Ex 1): Build a header Row: DateTile, a weighted title/details Column, then RsvpButton.
    //   Keep the description below the Row. Use 12.dp gaps and vertically center the Row's children.
    // TODO (Ex 2): Style the outer Column: 20.dp outside, full width, 16.dp rounded corners,
    //   a surfaceVariant background, and 16.dp inside. See the README's modifier walkthrough.
    // TODO (Ex 4): Title = typography.titleMedium; details = typography.bodyMedium in colorScheme.onSurfaceVariant;
    //   description capped at 2 lines with an ellipsis (maxLines / overflow).
    Column(modifier) {
        DateTile()
        Text("Design meetup")
        Text("Thu 18:30 · Community hall")
        RsvpButton()
        Text("An evening of short talks about building small, friendly apps, followed by snacks and a lot of questions about layout.")
    }
}

/** A square "14 / OCT" calendar tile. */
@Composable
fun DateTile(modifier: Modifier = Modifier) {
    // TODO (Ex 3): Wrap this tile in a Box and add a small "NEW" badge on its top-end corner
    //   (Modifier.align(Alignment.TopEnd) on the badge; nudge it outward with .offset(x = 6.dp, y = (-6).dp)).
    Column(
        modifier
            .size(56.dp)
            .background(MaterialTheme.colorScheme.primaryContainer, RoundedCornerShape(12.dp)),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Text("14", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
        Text("OCT", style = MaterialTheme.typography.labelSmall)
    }
}

/** A pill-shaped "RSVP" button built from a Text + modifiers (no Material Button on purpose). */
@Composable
fun RsvpButton(modifier: Modifier = Modifier) {
    // TODO (Ex 4): Make it a pill: clip(CircleShape), background(colorScheme.primary), clickable { },
    //   then padding(horizontal = 16.dp, vertical = 8.dp); text color = colorScheme.onPrimary.
    //   The README explains why clickable comes before padding; no trial-and-error step is required.
    Text("RSVP", modifier)
}

@Preview(showBackground = true)
@Composable
private fun LessonScreenPreview() {
    MaterialTheme { LessonScreen() }
}
