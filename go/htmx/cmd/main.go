package main

import (
	"io"
	"text/template"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

type Templates struct {
	templates *template.Template
}

func (t *Templates) Render(w io.Writer, name string, data interface{}, c echo.Context) error {
	return t.templates.ExecuteTemplate(w, name, data)
}

func newTemplates() *Templates {
	t := &Templates{
		templates: template.Must(template.ParseGlob("views/*.html")),
	}
	return t
}

type Contact struct {
	Name  string
	Email string
}

func newContact(name, email string) Contact {
	return Contact{Name: name, Email: email}
}

type Data struct {
	Contacts []Contact
}

func newData() Data {
	return Data{Contacts: []Contact{
		newContact("John Doe", "jd@email.com"),
		newContact("Clara Doe", "cd@email.com"),
	}}
}

func (d *Data) hasEmail(email string) bool {
	for _, contact := range d.Contacts {
		if contact.Email == email {
			return true
		}
	}
	return false
}

type Form struct {
	Values map[string]string
	Errors map[string]string
}

func newForm() Form {
	return Form{
		Values: map[string]string{},
		Errors: map[string]string{},
	}
}

type Page struct {
	Form Form
	Data Data
}

func newPage() Page {
	return Page{Data: newData(), Form: newForm()}
}

func main() {
	e := echo.New()
	e.Use(middleware.Logger())

	page := newPage()
	e.Renderer = newTemplates()

	e.GET("/", func(c echo.Context) error {
		return c.Render(200, "index", page)
	})

	e.POST("/contacts", func(c echo.Context) error {
		name := c.FormValue("name")
		email := c.FormValue("email")

		if page.Data.hasEmail(email) {
			form := newForm()
			form.Values["name"] = name
			form.Values["email"] = email
			form.Errors["email"] = "Email already exists"
			return c.Render(422, "form", form)
		}

		contact := newContact(name, email)
		page.Data.Contacts = append(page.Data.Contacts, contact)
		c.Render(200, "form", newForm())
		return c.Render(200, "oob-contact", contact)
	})

	e.Logger.Fatal(e.Start(":8080"))
}
