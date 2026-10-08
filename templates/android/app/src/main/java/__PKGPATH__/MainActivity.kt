package __PKG__

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
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
    Text("Lesson __NUM__ · __TITLE__", modifier.padding(16.dp))
}

@Preview(showBackground = true)
@Composable
private fun LessonScreenPreview() {
    MaterialTheme { LessonScreen() }
}
