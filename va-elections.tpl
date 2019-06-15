<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Virginia 2019 Elections</title>
  <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">
  <style type="text/css">
    .democrat {
      font-weight: bold;
      color: white;
      text-align: center;
      background-color: blue;
    }
    .republican {
      font-weight: bold;
      color: white;
      text-align: center;
      background-color: red;
    }
    .empty {
      background-color: lightgray;
    }
    .number {
      text-align: right;
    }
  </style>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
  <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js"></script>
  <script type="text/javascript">
    jQuery(function () {
      var numberCol = {
        className: 'text-right',
        render: $.fn.dataTable.render.number(',', '.')
      };
      $('#races-table').DataTable({
        columns: [
          null,
          null,
          null,
          null,
          numberCol,
          numberCol,
          null,
          null,
          null,
          numberCol,
          numberCol,
          null,
          numberCol,
          numberCol,
          null,
          numberCol,
          numberCol,
          null
        ],
        paging: false
      });
    });
  </script>
</head>
<body>
<table id="races-table">
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
        <td data-order="<%- (/^H/.test(district) ? 1 : 2) * 1000 + +district.substr(2) %>"><%- district %></td>
        <% _.forEach(r, function (value, key) { %>
          <td<% if (/Margin/.test(key)) { %> <%= marginStyle(value) %>"<% }
            else if (key === 'Party') { %> class="<%= value === 'D' ? 'democrat' : 'republican' %>"<% }
            else if (Array.isArray(value) && !value.length) { %> class="empty"<% }
            else if (/^[\d,]+$/.test(value)) { %> class="number"<% } %>
          >
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
</body>
</html>
