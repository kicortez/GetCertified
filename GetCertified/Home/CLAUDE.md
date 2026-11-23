# Home

The Home tab only has placeholder content so far. It has no model, controller or service.

## Views

- `HomeView` wraps its content in its own `NavigationStack` with the title "Home", like the other tabs.
- A vertical `ScrollView` shows these sections, top to bottom:
  - A hero banner: a rounded rectangle filled with an accent gradient, with a headline and a subheadline.
  - "Popular Courses": a horizontal `ScrollView` of placeholder cards that snaps with `.viewAligned`.
  - "New Courses": the same kind of row.
  - "Tip of the Day": a card with a lightbulb icon and static text.
- Both rows use `courseRow(title:)`, which shows `placeholderCount` cards (6).

## Next steps

When Home shows real data, give it the View → Controller → Service layering used in Courses. It can likely reuse `CourseService` and the `Course` model to fill the rows.
