package com.example.lessons.l02eventcard

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
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

@Composable
fun LessonScreen(modifier: Modifier = Modifier) {
    // The screen fills the window; its child card can wrap its own height.
    Box(modifier.fillMaxSize(), contentAlignment = Alignment.TopStart) {
        EventCard()
    }
}

@Composable
fun EventCard(modifier: Modifier = Modifier) {
    Column(
        modifier
            .padding(20.dp)                                   // outside the background = "margin"
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant)
            .padding(16.dp),                                  // inside the background = "padding"
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            DateTile()
            // weight(1f) on the text column lets long titles shrink/wrap instead of pushing RSVP off-screen.
            Column(Modifier.weight(1f)) {
                Text("Design meetup", style = MaterialTheme.typography.titleMedium)
                Text(
                    "Thu 18:30 · Community hall",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            // The weighted text Column takes the remaining width; no extra weighted Spacer is needed.
            RsvpButton()
        }
        Text(
            "An evening of short talks about building small, friendly apps, followed by snacks and a lot of questions about layout.",
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

@Composable
fun DateTile(modifier: Modifier = Modifier) {
    // Box = layered children (RN: position: 'absolute' children inside a relative parent).
    Box(modifier) {
        Column(
            Modifier
                .size(56.dp)
                .background(MaterialTheme.colorScheme.primaryContainer, RoundedCornerShape(12.dp)),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Text("14", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
            Text("OCT", style = MaterialTheme.typography.labelSmall)
        }
        Text(
            "NEW",
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onError,
            modifier = Modifier
                .align(Alignment.TopEnd)          // only available inside a Box's content (BoxScope)
                .offset(x = 6.dp, y = (-6).dp)    // offset moves drawing, not layout
                .background(MaterialTheme.colorScheme.error, CircleShape)
                .border(2.dp, MaterialTheme.colorScheme.surfaceVariant, CircleShape) // ring on top
                .padding(horizontal = 6.dp, vertical = 2.dp),
        )
    }
}

@Composable
fun RsvpButton(modifier: Modifier = Modifier) {
    Text(
        "RSVP",
        color = MaterialTheme.colorScheme.onPrimary,
        style = MaterialTheme.typography.labelLarge,
        modifier = modifier
            .clip(CircleShape)
            .background(MaterialTheme.colorScheme.primary)
            .clickable { }                        // before padding: the whole pill is tappable + ripples
            .padding(horizontal = 16.dp, vertical = 8.dp),
    )
}

@Preview(showBackground = true)
@Composable
private fun LessonScreenPreview() {
    MaterialTheme { LessonScreen() }
}
