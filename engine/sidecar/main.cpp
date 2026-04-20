// Fognitix engine sidecar: line-delimited JSON requests on stdin, responses on stdout.
// No Qt dependency — intended to be spawned by the Tauri host (or any IPC client).

#include <iostream>
#include <string>

static bool isSpace(unsigned char c)
{
    return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\v' || c == '\f';
}

static bool parseIntField(const std::string& line, const char* key, int& out)
{
    const std::string needle = std::string("\"") + key + "\"";
    const auto p = line.find(needle);
    if (p == std::string::npos) {
        return false;
    }
    auto colon = line.find(':', p + needle.size());
    if (colon == std::string::npos) {
        return false;
    }
    std::size_t i = colon + 1;
    while (i < line.size() && isSpace(static_cast<unsigned char>(line[i]))) {
        ++i;
    }
    if (i >= line.size()) {
        return false;
    }
    try {
        std::size_t consumed = 0;
        out = std::stoi(line.substr(i), &consumed);
        (void)consumed;
        return true;
    } catch (...) {
        return false;
    }
}

static bool containsMethod(const std::string& line, const char* method)
{
    const std::string needle = std::string("\"method\"") + ":";
    auto p = line.find(needle);
    if (p == std::string::npos) {
        return false;
    }
    p += needle.size();
    while (p < line.size() && isSpace(static_cast<unsigned char>(line[p]))) {
        ++p;
    }
    if (p < line.size() && line[p] == '"') {
        ++p;
    }
    const std::string m(method);
    return line.compare(p, m.size(), m) == 0;
}

static void emit(int id, const std::string& body)
{
    std::cout << "{\"id\":" << id << ',' << body << "}\n";
    std::cout.flush();
}

int main()
{
    std::ios::sync_with_stdio(false);
    std::string line;
    while (std::getline(std::cin, line)) {
        if (line.empty()) {
            continue;
        }
        int id = 0;
        (void)parseIntField(line, "id", id);

        if (containsMethod(line, "ping")) {
            emit(id, "\"result\":{\"ok\":true}");
        } else if (containsMethod(line, "version")) {
            emit(id, "\"result\":{\"name\":\"fognitix-engine\",\"version\":\"0.1.0\"}");
        } else {
            emit(id, "\"error\":{\"code\":-32601,\"message\":\"method not found\"}");
        }
    }
    return 0;
}
