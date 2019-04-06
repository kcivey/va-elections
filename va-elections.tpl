<table>
  <thead>
  <tr>
    <% _.forEach(headers, function (header) { %>
      <th><%- header %></th>
    <% }); %>
  </tr>
  </thead>
  <tbody>
    <% _.forEach(data, function (r, district) { %>
      <tr>
        <td><%- district %></td>
        <% _.forEach(r, function (value) { %>
          <td>
            <% if (Array.isArray(value)) { %>
              <% _.forEach(value, function (v) { %>
                <%- v %><br>
              <% }); %>
            <% } else { %>
              <%- value %>
            <% } %>
          </td>
        <% }); %>
      </tr>
    <% }); %>
  </tbody>
</table>
